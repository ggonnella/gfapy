GFA = Class.new
require_relative "./gfa/optfield.rb"
require_relative "./gfa/line.rb"
require_relative "./gfa/cigar.rb"
require_relative "./gfa/sequence.rb"
require_relative "./gfa/connect.rb"
require_relative "./gfa/line_getters.rb"
require_relative "./gfa/line_setters.rb"
require_relative "./gfa/edit.rb"
require_relative "./gfa/traverse.rb"

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
# - @connect["L"|"C"][:from|:to][segment_name]["+"|"-"] and
#   @paths_with[segment_name] are hashes of indices of
#   @lines["L"|"C"|"P"] which allow to directly find the links, containments
#   and paths involving a given segment; they must be updated if links,
#   containments or paths are added or deleted
# - The @connect data structure shall not be used directly, but using
#   the methods connections(), connect() and disconnect()
class GFA

  include GFA::LineGetters
  include GFA::LineSetters
  include GFA::Connect
  include GFA::Edit
  include GFA::Traverse

  def initialize(segments_first_order: false)
    @lines = {}
    GFA::Line::RecordTypes.keys.each {|rt| @lines[rt] = []}
    @segment_names = []
    @path_names = []
    @connect = {}
    ["L","C"].each {|rt| @connect[rt] = {:from => {}, :to => {}}}
    @paths_with = {}
    @segments_first_order = segments_first_order
  end

  # List all names of segments in the graph
  def segment_names
    @segment_names.compact
  end

  # List all names of path lines in the graph
  def path_names
    @path_names.compact
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

  # Creats a GFA instance reading from file with specified +filename+
  def self.from_file(filename)
    gfa = GFA.new
    File.foreach(filename) {|line| gfa << line.chomp}
    gfa.validate!
    return gfa
  end

  # Write GFA to file with specified +filename+;
  # overwrites it if it exists
  def to_file(filename)
    File.open(filename, "w") {|f| f.puts self}
  end

end

class String

  # Converts a string into a +GFA+ instance. Each line of the string is added
  # separately to the gfa.
  def to_gfa
    gfa = GFA.new
    split("\n").each {|line| gfa << line}
    gfa.validate!
    return gfa
  end

end

