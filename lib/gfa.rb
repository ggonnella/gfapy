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
# A representation of the GFA graph.
# Supports input and output from/to file or strings.
# Validates the input according to the GFA specification.
#
# *Internals*:
# - The main structures are the @lines arrays, one for each record_type
#   (e.g. header => @lines["H"]); these contain GFA::Line objects of the
#   corresponding subclass (e.g. GFA::Line::Header)
# - If an element is deleted, the position in @lines[record_type] is set to
#   +nil+, so that the links to all other positions still function
# - The @segment_names and @path_names arrays contain the names of
#   the segments and paths, in the same order as @lines["S"] and @lines["P"];
#   if a segment or path is added, its name is pushed on the @..._name array;
#   if a segment or path is deleted, its position on the @..._name array is set
#   to nil
# - @c contains array of indices of @lines["L"|"C"|"P"] which allow to directly
#   find the links, containments and paths involving a given segment; @c must
#   be updated if links, containments or paths are added or deleted
class GFA

  include GFA::LineGetters
  include GFA::LineCreators
  include GFA::LineDestructors
  include GFA::Edit
  include GFA::Traverse
  include GFA::Logger

  def initialize(segments_first_order: false)
    @lines = {}
    GFA::Line::RecordTypes.keys.each {|rt| @lines[rt] = []}
    @segment_names = {}
    @path_names = {}
    @c = GFA::ConnectionInfo.new(@lines)
    @segments_first_order = segments_first_order
    @validate = true
    @progress = false
  end

  # List all names of segments in the graph
  def segment_names
    @segment_names.keys.compact.map(&:to_s)
  end

  # List all names of path lines in the graph
  def path_names
    @path_names.keys.compact.map(&:to_s)
  end

  def turn_off_validations
    @validate = false
  end

  def validate!
    ["L", "C"].each do |rt|
      @lines[rt].each {|l| [:from,:to].each {|e| segment!(l.send(e))}}
    end
    @lines["P"].each {|l| l.segment_names.each {|sn, o| segment!(sn)}}
  end

  # Creates a string representation of GFA conforming to the current
  # specifications
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
  def to_gfa
    self
  end

  def clone
    to_s.to_gfa(validate: false)
  end

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
    validate! if validate
    self
  end

  # Creats a GFA instance reading from file with specified +filename+
  def self.from_file(filename, validate: true)
    gfa = GFA.new
    gfa.read_file(filename, validate: validate)
    return gfa
  end

  # Write GFA to file with specified +filename+;
  # overwrites it if it exists
  def to_file(filename)
    File.open(filename, "w") {|f| f.puts self}
  end

  def info(short = false)
    q, n50, tlen = lenstats
    nde = n_dead_ends()
    pde = "%.2f%%" % ((nde.to_f*100) / (segments.size*2))
    cc = connected_components()
    cc.map!{|c|c.map{|sn|segment!(sn).LN!}.inject(:+)}
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

  private

  def n_dead_ends
    segments.inject(0) do |n,s|
      [:E, :B].each {|e| n+= 1 if links_of([s.name, e]).empty?}
      n
    end
  end

  def lenstats
    sln = segments.map(&:LN!).sort
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

class String

  # Converts a +String+ into a +GFA+ instance. Each line of the string is added
  # separately to the gfa.
  def to_gfa(validate: true)
    gfa = GFA.new
    split("\n").each {|line| gfa << line}
    gfa.validate! if validate
    return gfa
  end

end

class Array

  # Converts an +Array+ of strings or GFA::Line instances
  # into a +GFA+ instance.
  def to_gfa(validate: true)
    gfa = GFA.new
    each {|line| gfa << line}
    gfa.validate! if validate
    return gfa
  end

end
