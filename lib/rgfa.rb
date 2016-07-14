#
# (c) 2016, Giorgio Gonnella, ZBH, Uni-Hamburg <gonnella@zbh.uni-hamburg.de>
#

RGFA = Class.new
require_relative "./rgfa/byte_array.rb"
require_relative "./rgfa/cigar.rb"
require_relative "./rgfa/connection_info.rb"
require_relative "./rgfa/field_parser.rb"
require_relative "./rgfa/field_validator.rb"
require_relative "./rgfa/field_writer.rb"
require_relative "./rgfa/edit.rb"
require_relative "./rgfa/line.rb"
require_relative "./rgfa/line_getters.rb"
require_relative "./rgfa/line_creators.rb"
require_relative "./rgfa/line_destructors.rb"
require_relative "./rgfa/logger.rb"
require_relative "./rgfa/numeric_array.rb"
require_relative "./rgfa/rgl.rb"
require_relative "./rgfa/segment_info.rb"
require_relative "./rgfa/sequence.rb"
require_relative "./rgfa/traverse.rb"

#
# This is the main class of the RGFA library.
# It provides a representation of the \RGFA graph.
# Supports creating a graph from scratch, input and output from/to file
# or strings, as well as several operations on the graph.
#
# *Internals*:
# - The main structures are the @lines arrays, one for each record_type
#   (e.g. header => @lines["H"]); these contain +RGFA::Line+ objects of the
#   corresponding subclass (e.g. +RGFA::Line::Header+)
# - If an element is deleted, the position in @lines[record_type] is set to
#   +nil+, so that the links to all other positions still function
# - The @segment_names and @path_names arrays contain the names of
#   the segments and paths, in the same order as @lines[:S] and @lines[:P];
#   if a segment or path is added, its name is pushed on the @..._name array;
#   if a segment or path is deleted, its position on the @..._name array is set
#   to nil
# - @c contains a RGFA::ConnectionInfo object, with hashes of indices of
#   @lines["L"|"C"|"P"] which allow to directly
#   find the links, containments and paths involving a given segment; @c is
#   kept uptodate by the methods which allow to delete/rename or add links,
#   containments or paths
class RGFA

  include RGFA::LineGetters
  include RGFA::LineCreators
  include RGFA::LineDestructors
  include RGFA::Edit
  include RGFA::Traverse
  include RGFA::LoggerSupport
  include RGFA::RGL

  def initialize
    @lines = {}
    RGFA::Line::RECORD_TYPES.each {|rt| @lines[rt] = []}
    @segment_names = {}
    @path_names = {}
    @c = RGFA::ConnectionInfo.new(@lines, @segment_names)
    @segments_first_order = false
    @validate = true
    @progress = false
    @default = {:count_tag => :RC, :unit_length => 1}
  end

  # Require that the links, containments and paths referring
  # to a segment are added after the segment. Default: do not
  # require any particular ordering.
  #
  # @return [void]
  def require_segments_first_order
    @segments_first_order = true
  end

  # Turns off validations. This increases the performance.
  # @return [void]
  def turn_off_validations
    @validate = false
  end

  # List all names of segments in the graph
  # @return [Array<String>]
  def segment_names
    @segment_names.keys.compact
  end

  # List all names of path lines in the graph
  # @return [Array<String>]
  def path_names
    @path_names.keys.compact
  end

  # Post-validation of the RGFA; checks that L, C and P refer to
  # existing S.
  # @return [void]
  # @raise if validation fails
  def validate!
    # todo this should also call validate in cascade to all records
    [:L, :C].each do |rt|
      @lines[rt].each {|l| [:from,:to].each {|e| segment!(l.send(e))}}
    end
    @lines[:P].each {|l| l.segment_names.each {|sn, o| segment!(sn)}}
  end

  # Creates a string representation of RGFA conforming to the current
  # specifications
  # @return [String]
  def to_s
    s = ""
    each_line {|line| s << line.to_s; s << "\n"}
    return s
  end

  # Return the gfa itself
  # @return [self]
  def to_rgfa
    self
  end

  # Create a deep copy of the RGFA instance.
  # @return [RGFA]
  def clone
    cpy = to_s.to_rgfa(validate: false)
    cpy.turn_off_validations if !@validate
    cpy.enable_progress_logging if @progress
    cpy.require_segments_first_order if @segments_first_order
    return cpy
  end

  # Populates a RGFA instance reading from file with specified +filename+
  # @param [boolean] validate <i>(default: +true+ if +#turn_off_validations+
  #   was never called, +false+ otherwise)</i> calls #validate! after
  #   construction of the graph (note: setting it to false does not deactivate
  #   all validations; for this use #turn_off_validations)
  # @param [String] filename
  # @raise if file cannot be opened for reading
  # @return [self]
  def read_file(filename, validate: @validate)
    if @progress
      linecount = `wc -l #{filename}`.strip.split(" ")[0].to_i
      progress_log_init(:read_file, "lines", linecount,
                        "Parse file with #{linecount} lines")
    end
    File.foreach(filename) do |line|
      self << line.chomp
      progress_log(:read_file) if @progress
    end
    progress_log_end(:read_file) if @progress
    validate! if validate
    self
  end

  # Creates a RGFA instance parsing the file with specified +filename+
  # @param [Boolean] validate <i>(default: true)</i> calls #validate! after
  #   construction of the graph (note: setting it to false does not deactivate
  #   all validations; for this use #turn_off_validations)
  # @param [String] filename
  # @raise if file cannot be opened for reading
  # @return [RGFA]
  def self.from_file(filename, validate: true)
    gfa = RGFA.new
    gfa.read_file(filename, validate: validate)
    return gfa
  end

  # Write RGFA to file with specified +filename+;
  # overwrites it if it exists
  # @param [String] filename
  # @raise if file cannot be opened for writing
  # @return [void]
  def to_file(filename)
    File.open(filename, "w") {|f| each_line {|l| f.puts l}}
  end

  #
  # @param [boolean] short compact output as a single text line
  #
  # Compact output has the following keys:
  # - +ns+: number of segments
  # - +nl+: number of links
  # - +cc+: number of connected components
  # - +de+: number of dead ends
  # - +tl+: total length of segment sequences
  # - +50+: N50 segment sequence length
  #
  # Normal output outputs a table with the same information, plus the largest
  # component, the shortest and largest and 1st/2nd/3rd quartiles
  # of segment sequence length.
  #
  # @return [String] sequence and topology information collected from the graph.
  #
  def info(short = false)
    q, n50, tlen = lenstats
    nde = n_dead_ends()
    pde = "%.2f%%" % ((nde.to_f*100) / (segments.size*2))
    cc = connected_components()
    cc.map!{|c|c.map{|sn|segment!(sn).length!}.inject(:+)}
    if short
      return "ns=#{segments.size}\t"+
             "nl=#{links.size}\t"+
             "cc=#{cc.size}\t"+
             "de=#{nde}\t"+
             "tl=#{tlen}\t"+
             "50=#{n50}"
    end
    retval = []
    retval << "Segment count:               #{segments.size}"
    retval << "Links count:                 #{links.size}"
    retval << "Total length (bp):           #{tlen}"
    retval << "Dead ends:                   #{nde}"
    retval << "Percentage dead ends:        #{pde}"
    retval << "Connected components:        #{cc.size}"
    retval << "Largest component (bp):      #{cc.last}"
    retval << "N50 (bp):                    #{n50}"
    retval << "Shortest segment (bp):       #{q[0]}"
    retval << "Lower quartile segment (bp): #{q[1]}"
    retval << "Median segment (bp):         #{q[2]}"
    retval << "Upper quartile segment (bp): #{q[3]}"
    retval << "Longest segment (bp):        #{q[4]}"
    return retval
  end

  # Counts the dead ends
  # (i.e. segment ends without connections)
  #
  # @return [Integer] number of dead ends in the graph
  #
  def n_dead_ends
    segments.inject(0) do |n,s|
      [:E, :B].each {|e| n+= 1 if links_of([s.name, e]).empty?}
      n
    end
  end

  private

  def lenstats
    sln = segments.map(&:length!).sort
    n = sln.size
    tlen = sln.inject(:+)
    n50 = nil
    sum = 0
    sln.reverse.each do |l|
      sum += l
      if sum >= tlen/2
        n50 = l
        break
      end
    end
    q = [sln[0], sln[(n/4)-1], sln[(n/2)-1], sln[((n*3)/4)-1], sln[-1]]
    return q, n50, tlen
  end

  # for tests
  def validate_connect
    @c.validate!
  end

end

# Ruby core String class, with additional methods.
class String

  # Converts a +String+ into a +RGFA+ instance. Each line of the string is added
  # separately to the gfa.
  # @return [RGFA]
  # @param [Boolean] validate <i>(defaults to: +true+)</i> #validate! after
  #   construction of the graph (note: setting it to false does not deactivate
  #   all validations; for this use #turn_off_validations)
  def to_rgfa(validate: true)
    gfa = RGFA.new
    split("\n").each {|line| gfa << line}
    gfa.validate! if validate
    return gfa
  end

end

# Ruby core Array class, with additional methods.
class Array

  # Converts an +Array+ of strings or RGFA::Line instances
  # into a +RGFA+ instance.
  # @return [RGFA]
  # @param [Boolean] validate <i>(defaults to: +true+)</i> #validate! after
  #   construction of the graph (note: setting it to false does not deactivate
  #   all validations; for this use #turn_off_validations)
  def to_rgfa(validate: true)
    gfa = RGFA.new
    each {|line| gfa << line}
    gfa.validate! if validate
    return gfa
  end

end
