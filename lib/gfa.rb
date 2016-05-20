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

  # TODO: as link and containment are low level, from_orient/to_orient/pos
  #       should be mandatory and the return value should be an array
  #       of all elements satisfying the conditions

  # Searches a link with from segment name +from+ and to segment name +to+.
  #
  # *Arguments*:
  #   - +from+/+to+: the segment names
  #   - +from_orient+/+to_orient+: optional, the orientation;
  #                                if not specified, then any orientation
  #                                is accepted
  #
  # *Returns*:
  #   - nil if the desired link does not exist
  #   - a GFA::Line::Link instance otherwise
  #   - if multiple links satisfy the conditions, the first one found is
  #     returned
  def link(from, to, from_orient: nil, to_orient: nil)
    link_or_containment("L", from, from_orient, to, to_orient, nil)
  end

  # Calls +link+ and raises a +RuntimeError+ if no path was found.
  def link!(from, to, from_orient: nil, to_orient: nil)
    l = link(from, to, from_orient: from_orient, to_orient: to_orient)
    raise "No link found" if l.nil?
    l
  end

  # Searches a containment of +to+ into +from+.
  #
  # *Arguments*:
  #   - +from+/+to+: the segment names
  #   - +from_orient+/+to_orient+: optional, the orientation;
  #                                if not specified, then any orientation
  #                                is accepted
  #   - +pos+: optional, the starting position;
  #            if not specified, then any position is accepted
  #
  # *Returns*:
  #   - nil if the desired containment does not exist
  #   - a GFA::Line::Containment instance otherwise
  #   - if multiple containments satisfy the conditions, the first one found is
  #     returned
  def containment(from, to, from_orient: nil, to_orient: nil, pos: nil)
    link_or_containment("C", from, from_orient, to, to_orient, pos)
  end

  # Calls +containment+ and raises a +RuntimeError+ if no path was found.
  def containment!(from, to, from_orient: nil, to_orient: nil, pos: nil)
    c = containment(from, to, from_orient: from_orient, to_orient: to_orient,
                    pos: pos)
    raise "No containment found" if c.nil?
    c
  end

  # TODO: delete these methods
  ["links", "containments"].each do |c|
    rt = c[0].upcase
    [:from, :to].each do |d|
      define_method(:"#{c}_#{d}") do |segment_name, orientation = nil|
        connections(rt, d, segment_name, orientation).map do |i|
          @lines[rt][i]
        end
      end
    end
  end

  # TODO: make this method private
  def lines(record_type)
    retval = []
    each(record_type) {|l| retval << l}
    return retval
  end

  def paths_with(segment_name)
    @paths_with.fetch(segment_name,[]).map{|i|@lines["P"][i]}
  end

  GFA::Line::RecordTypes.each do |rt, klass|
    klass =~ /GFA::Line::(.*)/
    define_method(:"#{$1.downcase}s") { lines(rt) }
    define_method(:"each_#{$1.downcase}") { each(rt) }
  end

  def segment_names
    @segment_names.compact
  end

  def path_names
    @path_names.compact
  end

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

  def to_gfa
    self
  end

  def self.from_file(filename)
    gfa = GFA.new
    File.foreach(filename) {|line| gfa << line.chomp}
    return gfa
  end

  def to_file(filename)
    File.open(filename, "w") {|f| f.puts self}
  end

  # Assigns a segment to a connectivity class depending on the number of links
  # to the beginning and to the end of its sequence.
  #
  # *Arguments*:
  #   - +segment_name+: name of the segment
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
  #
  def segment_junction_type(segment_name, reverse_complement = false)
    ends = [:B, :E]
    ends.reverse! if reverse_complement
    junction_type(links_of_segment_end(segment_name, ends.first).size,
                  links_of_segment_end(segment_name, ends.last).size)
  end

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

  # Find links of the specified end of segment
  #
  # *Returns*
  #   - An array of GFA::Line::Link containing:
  #     - if end_type == :E
  #       links from sn with to_orient +
  #       links to sn   with to_orient -
  #     - if end_type == :B
  #       links to sn   with to_orient +
  #       links from sn with to_orient -
  #
  # *Note*:
  #   - To add or remove links, use +connect()+ or +disconnect()+;
  #     adding or removing links from the returned array will not work
  def links_of_segment_end(sn, end_type)
    if end_type == :E
      c=connections("L",:from,sn,"+")+connections("L",:to,sn,"-")
    elsif end_type == :B
      c=connections("L",:to,sn,"+")+connections("L",:from,sn,"-")
    else
      raise "end_type unknown: #{end_type.inspect}"
    end
    c.map {|i| @lines['L'][i]}
  end

  def link_of_segment_ends(sn1, end_type1, sn2, end_type2)
  end

  # As +link_of_segment_ends+, but raises an RuntimeError if no
  # link could be found.
  def link_of_segment_ends!(sn1, end_type1, sn2, end_type2)
  end

  private

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

  # Searches for a link (if +rt == "L"+) or containment (if +rt == "C"+)
  # connecting segments +from+ and +to+. The orientation and starting pos
  # (the latter for containments only) must match only if not +nil+.
  # The first L or C found is returned, +nil+ if nothing matches.
  def link_or_containment(rt, from, from_orient, to, to_orient, pos)
    connections(rt, :from, from).each do |li|
      l = @lines[rt][li]
      if (l.to == to) and
         (to_orient.nil? or (l.to_orient == to_orient)) and
         (from_orient.nil? or (l.from_orient == from_orient)) and
         (pos.nil? or (l.pos(false) == pos.to_s))
        return l
      end
    end
    return nil
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
      after  = links_of_segment_end(current_elem, traverse_from_E_end ? :E : :B)
      before = links_of_segment_end(current_elem, traverse_from_E_end ? :B : :E)
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

