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
    junction_type(end_links(segment_name, ends.first).size,
                  end_links(segment_name, ends.last).size)
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

  # Searches the segment with name equal to +segment_name+.
  #
  # *Raises*:
  #   - +RuntimeError+ if no such segment exists in the gfa
  #
  # *Returns*:
  #   - a GFA::Line::Segment instance
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

  # Searches the path with name equal to +path_name+.
  #
  # *Raises*:
  #   - +RuntimeError+ if no such path exists in the gfa
  #
  # *Returns*:
  #   - a GFA::Line::Path instance
  def path!(path_name)
    pt = path(path_name)
    raise "No path has name #{path_name}" if pt.nil?
    pt
  end

  # Searches a link between +to+ and +from+.
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

  # Searches a link between +to+ and +from+.
  #
  # *Arguments*:
  #   - +from+/+to+: the segment names
  #   - +from_orient+/+to_orient+: optional, the orientation;
  #                                if not specified, then any orientation
  #                                is accepted
  #
  # *Raises:
  #   - +RuntimeError+ if the desired link does not exist
  #
  # *Returns*:
  #   - a GFA::Line::Link instance otherwise
  #   - if multiple links satisfy the conditions, the first one found is
  #     returned
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
  # *Raises:
  #   - +RuntimeError+ if the desired containment does not exist
  #
  # *Returns*:
  #   - a GFA::Line::Containment instance otherwise
  #   - if multiple containments satisfy the conditions, the first one found is
  #     returned
  def containment!(from, to, from_orient: nil, to_orient: nil, pos: nil)
    c = containment(from, to, from_orient: from_orient, to_orient: to_orient,
                    pos: pos)
    raise "No containment found" if c.nil?
    c
  end

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

  def paths_with(segment_name)
    @paths_with.fetch(segment_name,[]).map{|i|@lines["P"][i]}
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

  GFA::Line::RecordTypes.each do |rt, klass|
    klass =~ /GFA::Line::(.*)/
    define_method(:"#{$1.downcase}s") { lines(rt) }
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

  def unbranched_segpaths
    exclude = Set.new
    paths = []
    @segment_names.each_with_index do |sn, i|
      next if exclude.include?(sn)
      jt = segment_junction_type(sn)
      if segment_junction_type(sn) == :internal
        exclude << sn
        segpath = traverse_internals(sn, false, exclude).reverse +
                  traverse_internals(sn, true, exclude)[1..-1]
        next if segpath.size < 2
        paths << segpath
      elsif [:junction_M1, :end_01].include?(jt)
        exclude << sn
        segpath = traverse_internals(sn, true, exclude)
        next if segpath.size < 2
        paths << segpath
      elsif [:junction_1M, :end_10].include?(jt)
        exclude << sn
        segpath = traverse_internals(sn, false, exclude).reverse
        next if segpath.size < 2
        paths << segpath
      end
    end
    return paths
  end

  private

  # Find connections from specified end of segment
  # (E=from+/to- connections; B=from-/to+ connections)
  #
  # *Note*:
  # The specified array should only be read, as it is often a
  # copy of the original; thus modifications must be done using
  # +connect()+ or +disconnect()+
  def end_links(sn, end_type)
    if end_type == :E
      c=connections("L",:from,sn,"+")+connections("L",:to,sn,"-")
    elsif end_type == :B
      c=connections("L",:to,sn,"+")+connections("L",:from,sn,"-")
    else
      raise "end_type unknown: #{end_type.inspect}"
    end
    c.map {|i| @lines['L'][i]}
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

  def traverse_internals(from, direct_direction, exclude)
    list = []
    current_elem = from
    loop do
      blist = end_links(current_elem, :B)
      elist = end_links(current_elem, :E)
      jt = direct_direction ? junction_type(blist.size, elist.size)
                            : junction_type(elist.size, blist.size)
      if jt == :internal or list.empty?
        list << current_elem
        l = direct_direction ? elist.first : blist.first
        current_elem = l.other(current_elem)
        if (l.end_type(current_elem) == :B and !direct_direction) or
           (l.end_type(current_elem) == :E and direct_direction)
          direct_direction = !direct_direction
        end
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

