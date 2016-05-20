GFA = Class.new
require_relative "./gfa/optfield.rb"
require_relative "./gfa/line.rb"
require_relative "./gfa/edit.rb"
require_relative "./gfa/cigar.rb"
require_relative "./gfa/sequence.rb"
require "set"

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

  include GFA::Edit

  def initialize
    @lines = {}
    GFA::Line::RecordTypes.keys.each {|rt| @lines[rt] = []}
    @segment_names = []
    @path_names = []
    @connect = {}
    ["L","C"].each {|rt| @connect[rt] = {:from => {}, :to => {}}}
    @paths_with = {}
  end

  # List all names of segments in the graph
  def segment_names
    @segment_names.compact
  end

  # Searches the segment with name equal to +segment_name+.
  #
  # *Returns*:
  #   - +nil+ if no such segment exists in the gfa
  #   - a GFA::Line::Segment instance otherwise
  def segment(segment_name)
    i = @segment_names.index(segment_name)
    i.nil? ? nil : @lines["S"][i]
  end

  # Calls +segment+ and raises a +RuntimeError+ if no segment was found.
  def segment!(segment_name)
    s = segment(segment_name)
    raise "No segment has name #{segment_name}" if s.nil?
    s
  end

  # List all names of path lines in the graph
  def path_names
    @path_names.compact
  end

  # Searches the path with name equal to +path_name+.
  #
  # *Returns*:
  #   - +nil+ if no such path exists in the gfa
  #   - a GFA::Line::Path instance otherwise
  def path(path_name)
    i = @path_names.index(path_name)
    i.nil? ? nil : @lines["P"][i]
  end

  # Calls +path+ and raises a +RuntimeError+ if no path was found.
  def path!(path_name)
    pt = path(path_name)
    raise "No path has name #{path_name}" if pt.nil?
    pt
  end

  # Find path lines whose +segment_names+ include segment +segment_name+
  def paths_with(segment_name)
    @paths_with.fetch(segment_name,[]).map{|i|@lines["P"][i]}
  end

  # Find containment lines whose +from+ segment name is +segment_name+
  def contained_in(segment_name)
    connection_lines("C", :from, segment_name)
  end

  # Find containment lines whose +to+ segment name is +segment_name+
  def containing(segment_name)
    connection_lines("C", :to, segment_name)
  end

  # Searches all containments of +contained+ in +container+.
  #
  # Returns a possibly empty array of containments.
  def containments_between(container, contained)
    contained_in(container).select {|l| l.to == contained }
  end

  # Searches a containment of +contained+ in +container+.
  #
  # Returns the first containment found or nil if none found.
  def containment(container, contained)
    contained_in(container).each {|l| return l if l.to == contained }
    return nil
  end

  # Calls +containment+ and raises a +RuntimeError+ if no containment was found.
  def containment!(container, contained)
    c = containment(container, contained)
    raise "No containment was found" if c.nil?
    c
  end

  # Find links of the specified end of segment
  #
  # *Returns*
  #   - An array of GFA::Line::Link containing:
  #     - if end_type == :E
  #       links from sn with from_orient +
  #       links to   sn with to_orient   -
  #     - if end_type == :B
  #       links to   sn with to_orient   +
  #       links from sn with from_orient -
  #     - if end_type == nil
  #       all links of sn
  #
  # *Note*:
  #   - To add or remove links, use +connect()+ or +disconnect()+;
  #     adding or removing links from the returned array will not work
  def links_of(sn, end_type)
    case end_type
    when :E
      o = ["+","-"]
    when :B
      o = ["-","+"]
    when nil
      return links_of(sn, :B) + links_of(sn, :E)
    else
      raise "end_type unknown: #{end_type.inspect}"
    end
    connection_lines("L",:from,sn,o[0]) + connection_lines("L",:to,sn,o[1])
  end

  # Searches all links between the segment +sn1+ end +end_type1+
  # and the segment +sn2+ end +end_type2+
  #
  # The end_types can be set to nil, in which case both ends are searched.
  #
  # Returns a possibly empty array of links.
  def links_between(sn1, end_type1, sn2, end_type2)
    links_of(sn, end_type1).select do |l|
      l.other(sn1) == sn2 and
        (end_type2.nil? or l.other_end_type(sn1) == end_type2)
    end
  end

  # Searches a link between the segment +sn1+ end +end_type1+
  # and the segment +sn2+ end +end_type2+
  #
  # The end_types can be set to nil, in which case both ends are searched.
  #
  # Returns the first link found or nil if none found.
  def link(sn1, end_type1, sn2, end_type2)
    links_of(sn1, end_type1).each do |l|
      return l if l.other(sn1) == sn2 and
        (end_type2.nil? or l.other_end_type(sn1) == end_type2)
    end
    return nil
  end

  # Calls +link+ and raises a +RuntimeError+ if no link was found.
  def link!(sn1, end_type1, sn2, end_type2)
    l = link(sn1, end_type1, sn2, end_type2)
    raise "No link was found" if l.nil?
    l
  end

  # TODO: move segment_junction_type, unbranched_segpath etc into an own module
  #       GFA::Traverse

  # Computes the connectivity class of a segment depending on the number
  # of links to the beginning and to the end of its sequence.
  #
  # *Arguments*:
  #   - +segment_name+: name of the segment
  #   - +reverse_complement+ use the reverse complement of the segment sequence
  #
  # *Returns*:
  #   (bn = number of links to the beginning of the sequence;
  #    en = number of links to the end of the sequence;
  #    b = "M" if bn > 1, otherwise bn;
  #    e = "M" if en > 1, otherwise en)
  #   - +:isolated+            if: bn == 0, en == 0
  #   - +:end_#{b}#{e}>+       if: bn or en == 0, other > 0
  #   - +:internal+            if: bn == 1, en == 1
  #   - +:junction_#{b}#{e}>+  if: bn or en == 1, other > 1
  #   - if +reverse_complement+ is set to true, b/e are switched
  #     (nothing changes for :isolated/:internal)
  #
  def segment_junction_type(segment_name, reverse_complement = false)
    ends = [:B, :E]
    ends.reverse! if reverse_complement
    junction_type(links_of(segment_name, ends.first).size,
                  links_of(segment_name, ends.last).size)
  end

  # Find a path without branches which includes segment +segment_name+
  # and excludes any segment whose name is stored in +exclude+.
  #
  # *Side effects*:
  #   - any segment used in the path will be added to +exclude+
  #
  # *Returns*:
  #   - an array of segment names
  def unbranched_segpath(segment_name, exclude = Set.new)
    jt = segment_junction_type(segment_name)
    case jt
    when :internal
      exclude << segment_name
      segpath = traverse_unbranched(segment_name, false, exclude).reverse +
                traverse_unbranched(segment_name, true, exclude)[1..-1]
    when :junction_M1, :end_01
      exclude << segment_name
      segpath = traverse_unbranched(segment_name, true, exclude)
    when :junction_1M, :end_10
      exclude << segment_name
      segpath = traverse_unbranched(segment_name, false, exclude).reverse
    else
      return nil
    end
    return nil if segpath.size < 2
    segpath
  end

  # Find all unbranched paths of segments connected by links in the graph.
  def unbranched_segpaths
    exclude = Set.new
    paths = []
    @segment_names.each_with_index do |sn, i|
      next if exclude.include?(sn)
      paths << unbranched_segpath(sn, exclude)
    end
    return paths.compact
  end

  GFA::Line::RecordTypes.each do |rt, klass|
    klass =~ /GFA::Line::(.*)/
    define_method(:"#{$1.downcase}s") { lines(rt) }
    define_method(:"each_#{$1.downcase}") { each(rt) }
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
    return gfa
  end

  # Write GFA to file with specified +filename+;
  # overwrites it if it exists
  def to_file(filename)
    File.open(filename, "w") {|f| f.puts self}
  end

  private

  def connection_lines(rt, dir, sn, o = nil)
    connections(rt, dir, sn, o).map{|i| @lines[rt][i]}
  end

  # Enumerate values from @connect data structure
  #
  # *Usage*:
  # +connections(rt, :from|:to, sn)+ => both orientations of +sn+
  # +connections(rt, :from|:to, sn, :+|:-)+ => only specified orientation
  #
  # *Note*:
  # The specified array should only be read, as it is often a
  # copy of the original; thus modifications must be done using
  # +connect()+ or +disconnect()+
  def connections(rt, dir, sn, o = nil)
    raise "RT invalid: #{rt.inspect}" if rt != "L" and rt != "C"
    raise "dir unknown: #{dir.inspect}" if dir != :from and dir != :to
    return connections(rt,dir,sn,"+")+connections(rt,dir,sn,"-") if o.nil?
    raise "o unknown: #{o.inspect}" if o != "+" and o != "-"
    @connect[rt][dir].fetch(sn,{}).fetch(o,[])
  end

  # See +segment_junction_type+
  def junction_type(b_list_size, e_list_size)
    b = b_list_size > 1 ? "M" : b_list_size
    e = e_list_size > 1 ? "M" : e_list_size
    if b == e and b != "M"
      return (b == 0) ? :isolated : :internal
    else
      return :"#{(b == 0 or e == 0) ? 'end' : 'junction'}_#{b}#{e}"
    end
  end

  # Traverse the links, starting from the segment +from+ :E end if
  # +traverse_from_E_end+ is true, or :B end otherwise.
  #
  # If any segment after +from+ is found whose name is included in +exclude+
  # the traversing is interrupted. The +exclude+ set is updated, so that
  # circular paths are avoided.
  #
  # *Arguments*:
  #   - +from+ -> first segment
  #   - +traverse_from_E_end+ -> if true, start from E end, otherwise from B end
  #   - +exclude+ -> Set of names of already visited segments
  #
  # *Side Effects*:
  #   - Any element added to the returned list is also added to +exclude+
  #
  # *Returns*:
  #   - An array of segment names of the unbranched path.
  #     If +from+ is not an element of an unbranched path then [].
  #     Otherwise the first (and possibly only) element is +from+.
  #     All elements in the index range 1..-2 are :internal.
  def traverse_unbranched(from, traverse_from_E_end, exclude)
    list = []
    current_elem = from
    loop do
      after  = links_of(current_elem, traverse_from_E_end ? :E : :B)
      before = links_of(current_elem, traverse_from_E_end ? :B : :E)
      jt = junction_type(before.size, after.size)
      if jt == :internal or list.empty?
        list << current_elem
        l = after.first
        current_elem = l.other(current_elem)
        traverse_from_E_end = (l.end_type(current_elem) == :B)
        return list if exclude.include?(current_elem)
        exclude << current_elem
      elsif [:junction_1M, :end_10].include?(jt)
        list << current_elem
        return list
      else
        return list
      end
    end
  end

  # Checks if all elements of connect refer to a link of containment
  # which was not deleted and whose from, to, from_orient, to_orient fields
  # have the expected values.
  #
  # Method useful for debugging.
  def validate_connect
    @connect.keys.each do |rt|
      @connect[rt].keys.each do |dir|
        @connect[rt][dir].keys.each do |sn|
          @connect[rt][dir][sn].keys.each do |o|
            @connect[rt][dir][sn][o].each do |li|
              l = @lines[rt][li]
              if l.nil? or l.send(dir) != sn or l.send(:"#{dir}_orient") != o
                raise "Error in connect\n"+
                  "@connect[#{rt}][#{dir.inspect}][#{sn}][#{o}]=#{li}\n"+
                  "@links[#{rt}][#{li}]=#{l.nil? ? l.inspect : l.to_s}"
              end
            end
          end
        end
      end
    end
  end

  def each(record_type)
    @lines[record_type].each do |line|
      next if line.nil?
      yield line
    end
  end

  def lines(record_type)
    retval = []
    each(record_type) {|l| retval << l}
    return retval
  end

end

class String

  # Converts a string into a +GFA+ instance. Each line of the string is added
  # separately to the gfa.
  def to_gfa
    gfa = GFA.new
    split("\n").each {|line| gfa << line}
    return gfa
  end

end

