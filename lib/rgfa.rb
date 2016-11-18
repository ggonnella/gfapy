# (c) 2016, Giorgio Gonnella, ZBH, Uni-Hamburg <gonnella@zbh.uni-hamburg.de>

# Main class of the RGFA library.
#
# RGFA provides a representation of a GFA graph.
# It supports creating a graph from scratch, input and output from/to file
# or strings, as well as several operations on the graph.
# The examples below show how to create a RGFA object from scratch or
# from a GFA file, write the RGFA to file, output the string representation or
# a statistics report, and control the validation level.
#
# == Interacting with the graph
#
# - {RGFA::Lines}: module with methods for finding, editing, iterating over,
#   removing lines belonging to a RGFA instance. Specialized modules exist
#   for each kind of line:
#   - {RGFA::Lines::Headers}: accessing and creating header information is done
#     using a single header line object ({#header RGFA#header})
#   - {RGFA::Lines::Segments}
#   - {RGFA::Lines::Edge::Links}
#   - {RGFA::Lines::Edge::Containments}
#   - {RGFA::Lines::Paths}
#   - {RGFA::Lines::Comments}
#   - {RGFA::Lines::Gaps}
#   - {RGFA::Lines::Fragments}
#   - {RGFA::Lines::Edge::GFA2s}
#   - {RGFA::Lines::OrderedGroups}
#   - {RGFA::Lines::UnorderedGroups}
#   - {RGFA::Lines::CustomRecords}
#
# - {RGFA::Line}: most interaction with the GFA involve interacting with
#   its record, i.e. instances of a subclass of this class. Subclasses:
#   - {RGFA::Line::Header}
#   - {RGFA::Line::Segment::GFA1}
#   - {RGFA::Line::Segment::GFA2}
#   - {RGFA::Line::Edge::Link}
#   - {RGFA::Line::Edge::Containment}
#   - {RGFA::Line::Edge::GFA2}
#   - {RGFA::Line::Group::Path}
#   - {RGFA::Line::Group::Ordered}
#   - {RGFA::Line::Group::Unordered}
#   - {RGFA::Line::Comment}
#   - {RGFA::Line::Gap}
#   - {RGFA::Line::Fragment}
#   - {RGFA::Line::CustomRecord}
#
# - Further modules contain methods useful for interacting with the graph
#   - {RGFA::GraphOperations::Connectivity} analysis of the graph connectivity
#   - {RGFA::GraphOperations::LinearPaths} finding and merging of linear paths
#   - {RGFA::GraphOperations::Multiplication} separation of the
#       implicit instances of a repeat
#
# - Additional functionality is provided by {RGFATools}
#
# @example Creating an empty RGFA object
#   gfa = RGFA.new
#
# @example Parsing and writing GFA format
#   gfa = RGFA.from_file(filename) # parse GFA file
#   gfa.to_file(filename) # write to GFA file
#   puts gfa # show GFA representation of RGFA object
#
# @example Basic statistics report
#   puts gfa.info # print report
#   puts gfa.info(short = true) # compact format, in one line
#
# @example Validation
#   gfa = RGFA.from_file(filename, validate: 1) # default level is 2
#   gfa.validate = 3 # change validation level
#   gfa.turn_off_validations # equivalent to gfa.validate = 0
#   gfa.validate # run post-validations (e.g. check segment names in links)
#
class RGFA
end

require_relative "./rgfa/alignment.rb"
require_relative "./rgfa/byte_array.rb"
require_relative "./rgfa/field_array.rb"
require_relative "./rgfa/field.rb"
require_relative "./rgfa/graph_operations.rb"
require_relative "./rgfa/line.rb"
require_relative "./rgfa/lines.rb"
require_relative "./rgfa/logger.rb"
require_relative "./rgfa/numeric_array.rb"
require_relative "./rgfa/placeholder.rb"
require_relative "./rgfa/lastpos.rb"
require_relative "./rgfa/segment_ends_path.rb"
require_relative "./rgfa/segment_info.rb"
require_relative "./rgfa/sequence.rb"

class RGFA

  include RGFA::Lines
  include RGFA::GraphOperations
  include RGFA::LoggerSupport

  # @!attribute [rw] validate
  #   @return [Integer (0..5)] validation level
  attr_accessor :validate

  # Recognized GFA specification versions
  VERSIONS = [:"1.0", :"2.0"]

  # @!attribute [r] version
  #   @return [RGFA::VERSIONS, nil] GFA specification version
  attr_reader :version

  # @!macro validate
  #   @param validate [Integer] (<i>defaults to: +2+</i>)
  #     the validation level; see "Validation level" under
  #     {RGFA::Line#initialize}.
  # @param version [RGFA::VERSIONS] GFA version, nil if unknown
  def initialize(validate: 2, version: nil)
    @validate = validate
    @records = {}
    @records[:H] = RGFA::Line::Header.new([], validate: @validate)
    [:S, :P, nil].each {|rt| @records[rt] = {}}
    [:E, :U, :G, :O].each {|rt| @records[rt] = {nil => []}}
    [:C, :L, :"#", :F].each {|rt| @records[rt] = []}
    @segments_first_order = false
    @progress = false
    @default = {:count_tag => :RC, :unit_length => 1}
    @extensions_enabled = false
    @line_queue = []
    if version.nil?
      @version = nil
      @version_explanation = nil
      @version_guess = :"2.0"
    else
      @version = version.to_sym
      @version_explanation = "set during initialization"
      @version_guess = @version
      validate_version
    end
  end

  # Require that the links, containments and paths referring
  # to a segment are added after the segment. Default: do not
  # require any particular ordering.
  #
  # @return [void]
  def require_segments_first_order
    @segments_first_order = true
  end

  attr_reader :segments_first_order

  # Set the validation level to 0.
  # See "Validation level" under {RGFA::Line#initialize}.
  # @return [void]
  def turn_off_validations
    @validate = 0
  end

  # Post-validation of the RGFA
  # @return [void]
  # @raise if validation fails
  def validation
    validate_segment_references
    validate_path_links
    return nil
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

  # Create a copy of the RGFA instance.
  # @return [RGFA]
  def clone
    cpy = to_s.to_rgfa(validate: 0)
    cpy.validate = @validate
    cpy.enable_progress_logging if @progress
    cpy.require_segments_first_order if @segments_first_order
    return cpy
  end

  # Populates a RGFA instance reading from file with specified +filename+
  # @param [String] filename
  # @raise if file cannot be opened for reading
  # @return [self]
  def read_file(filename)
    if @progress
      linecount = `wc -l #{filename}`.strip.split(" ")[0].to_i
      progress_log_init(:read_file, "lines", linecount,
                        "Parse file with #{linecount} lines")
    end
    File.foreach(filename) do |line|
      self << line.chomp
      progress_log(:read_file) if @progress
    end
    if !@line_queue.empty?
      @version = @version_guess
      process_line_queue
    end
    progress_log_end(:read_file) if @progress
    validate if @validate >= 1
    self
  end

  # Creates a RGFA instance parsing the file with specified +filename+
  # @param [String] filename
  # @raise if file cannot be opened for reading
  # @!macro validate
  # @param version [RGFA::VERSIONS] GFA version, nil if unknown
  # @return [RGFA]
  def self.from_file(filename, validate: 2, version: nil)
    gfa = RGFA.new(validate: validate, version: version)
    gfa.read_file(filename)
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

  # Output basic statistics about the graph's sequence and topology
  # information.
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
  # Normal output outputs a table with the same information, plus some
  # additional one: the length of the largest
  # component, as well as the shortest and largest and 1st/2nd/3rd quartiles
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
    retval << "Edge::Links count:                 #{links.size}"
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

  # Counts the dead ends.
  #
  # Dead ends are here defined as segment ends without connections.
  #
  # @return [Integer] number of dead ends in the graph
  #
  def n_dead_ends
    segments.inject(0) do |n,s|
      [:L, :R].each {|e| n+= 1 if s.dovetails(e).empty?}
      n
    end
  end

  # Compare two RGFA instances.
  # @return [Boolean] are the lines of the two instances equivalent?
  def ==(other)
    segments == other.segments and
      links == other.links and
      containments == other.containments and
      headers == other.headers and
      paths == other.paths
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

  # Checks that L, C and P refer to existing S.
  # @return [void]
  # @raise [RGFA::NotFoundError] if validation fails
  def validate_segment_references
    @records[:S].values.each do |s|
      if s.virtual?
        raise RGFA::NotFoundError, "Segment #{s.name} does not exist\n"+
            "References to #{s.name} were found in the following lines:\n"+
            s.all_references.map(&:to_s).join("\n")
      end
    end
    return nil
  end

  # Checks that P are supported by links.
  # @return [void]
  # @raise if validation fails
  def validate_path_links
    @records[:P].values.each do |pt|
      pt.links.each do |l, dir|
        if l.virtual?
          raise RGFA::NotFoundError, "Edge::Link: #{l.to_s}\n"+
          "does not exist, but is required by the following paths:\n"+
          l.paths.map(&:to_s).join("\n")
        end
      end
    end
    return nil
  end

  def validate_version
    if !@version.nil? and !RGFA::VERSIONS.include?(@version)
      raise RGFA::VersionError,
        "GFA specification version #{@version} not supported"
    end
  end

end

# Ruby core String class, with additional methods.
class String

  # Converts a +String+ into a +RGFA+ instance. Each line of the string is added
  # separately to the gfa.
  # @param version [RGFA::VERSIONS] GFA version, nil if unknown
  # @return [RGFA]
  # @!macro validate
  def to_rgfa(validate: 2, version: nil)
    gfa = RGFA.new(validate: validate, version: version)
    split("\n").each {|line| gfa << line}
    gfa.process_line_queue
    gfa.validate if validate >= 1
    return gfa
  end

end

# Ruby core Array class, with additional methods.
class Array

  # Converts an +Array+ of strings or RGFA::Line instances
  # into a +RGFA+ instance.
  # @param version [RGFA::VERSIONS] GFA version, nil if unknown
  # @return [RGFA]
  # @!macro validate
  def to_rgfa(validate: 2, version: nil)
    gfa = RGFA.new(validate: validate, version: version)
    each {|line| gfa << line}
    gfa.process_line_queue
    gfa.validate if validate >= 1
    return gfa
  end

end
