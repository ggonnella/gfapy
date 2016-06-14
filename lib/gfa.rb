#
# (c) 2016, Giorgio Gonnella, ZBH, Uni-Hamburg <gonnella@zbh.uni-hamburg.de>
#

GFA = Class.new
require_relative "./gfa/optfield.rb"
require_relative "./gfa/line.rb"
require_relative "./gfa/cigar.rb"
require_relative "./gfa/sequence.rb"
require_relative "./gfa/connection_info.rb"
require_relative "./gfa/line_getters.rb"
require_relative "./gfa/line_creators.rb"
require_relative "./gfa/line_destructors.rb"
require_relative "./gfa/edit.rb"
require_relative "./gfa/traverse.rb"
require_relative "./gfa/logger.rb"

#
# This is the main class of the RGFA library.
# It provides a representation of the \GFA graph.
# Supports creating a graph from scratch, input and output from/to file
# or strings, as well as several operations on the graph.
#
# *Internals*:
# - The main structures are the @lines arrays, one for each record_type
#   (e.g. header => @lines["H"]); these contain +GFA::Line+ objects of the
#   corresponding subclass (e.g. +GFA::Line::Header+)
# - If an element is deleted, the position in @lines[record_type] is set to
#   +nil+, so that the links to all other positions still function
# - The @segment_names and @path_names arrays contain the names of
#   the segments and paths, in the same order as @lines["S"] and @lines["P"];
#   if a segment or path is added, its name is pushed on the @..._name array;
#   if a segment or path is deleted, its position on the @..._name array is set
#   to nil
# - @c contains a GFA::ConnectionInfo object, with hashes of indices of
#   @lines["L"|"C"|"P"] which allow to directly
#   find the links, containments and paths involving a given segment; @c is
#   kept uptodate by the methods which allow to delete/rename or add links,
#   containments or paths
class GFA

  include GFA::LineGetters
  include GFA::LineCreators
  include GFA::LineDestructors
  include GFA::Edit
  include GFA::Traverse
  include GFA::LoggerSupport

  def initialize
    @lines = {}
    GFA::Line::RecordTypes.keys.each {|rt| @lines[rt] = []}
    @segment_names = {}
    @path_names = {}
    @c = GFA::ConnectionInfo.new(@lines)
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
    @segment_names.keys.compact.map(&:to_s)
  end

  # List all names of path lines in the graph
  # @return [Array<String>]
  def path_names
    @path_names.keys.compact.map(&:to_s)
  end

  # Post-validation of the GFA; checks that L, C and P refer to
  # existing S.
  # @return [void]
  # @raise if validation fails
  def validate!
    # todo this should also call validate in cascade to all records
    ["L", "C"].each do |rt|
      @lines[rt].each {|l| [:from,:to].each {|e| segment!(l.send(e))}}
    end
    @lines["P"].each {|l| l.segment_names.each {|sn, o| segment!(sn)}}
  end

  # Creates a string representation of GFA conforming to the current
  # specifications
  # @return [String]
  def to_s
    s = ""
    GFA::Line::RecordTypes.keys.each do |rt|
      @lines[rt].each do |line|
        next if line.nil?
        s << "#{line}\n"
      end
    end
    return s
  end

  # Return the gfa itself
  # @return [self]
  def to_gfa
    self
  end

  # Create a deep copy of the GFA instance.
  # @return [GFA]
  def clone
    cpy = to_s.to_gfa(validate: false)
    cpy.turn_off_validations if !@validate
    cpy.enable_progress_logging if @progress
    cpy.require_segments_first_order if @segments_first_order
    return cpy
  end

  # Populates a GFA instance reading from file with specified +filename+
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
    i = 0
    File.foreach(filename) do |line|
      self << line.chomp
      progress_log(:read_file) if @progress
      i += 1
    end
    progress_log_end(:read_file) if @progress
    validate! if validate
    self
  end

  # Creates a GFA instance parsing the file with specified +filename+
  # @param [boolean] validate <i>(default: true)</i> calls #validate! after
  #   construction of the graph (note: setting it to false does not deactivate
  #   all validations; for this use #turn_off_validations)
  # @param [String] filename
  # @raise if file cannot be opened for reading
  # @return [GFA]
  def self.from_file(filename, validate: true)
    gfa = GFA.new
    gfa.read_file(filename, validate: validate)
    return gfa
  end

  # Write GFA to file with specified +filename+;
  # overwrites it if it exists
  # @param [String] filename
  # @raise if file cannot be opened for writing
  # @return [void]
  def to_file(filename)
    File.open(filename, "w") {|f| f.puts self}
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

  # Converts a +String+ into a +GFA+ instance. Each line of the string is added
  # separately to the gfa.
  # @return [GFA]
  # @param [boolean] validate <i>(default: true)</i> calls #validate! after
  #   construction of the graph (note: setting it to false does not deactivate
  #   all validations; for this use #turn_off_validations)
  def to_gfa(validate: true)
    gfa = GFA.new
    split("\n").each {|line| gfa << line}
    gfa.validate! if validate
    return gfa
  end

end

# Ruby core Array class, with additional methods.
class Array

  # Converts an +Array+ of strings or GFA::Line instances
  # into a +GFA+ instance.
  # @return [GFA]
  # @param [boolean] validate <i>(default: true)</i> calls #validate! after
  #   construction of the graph (note: setting it to false does not deactivate
  #   all validations; for this use #turn_off_validations)
  def to_gfa(validate: true)
    gfa = GFA.new
    each {|line| gfa << line}
    gfa.validate! if validate
    return gfa
  end

end
