GFA = Class.new
require_relative "./gfa/optfield.rb"
require_relative "./gfa/line.rb"
require_relative "./gfa/edit.rb"
require_relative "./gfa/cigar.rb"
require_relative "./gfa/sequence.rb"

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
# - The @mark[record_type] are arrays which allow to set a mark,
#   e.g. "visited", which refer to the element at the same index in
#   @lines[record_type]. Methods may generally change marks as they wish
#   and do not expect any meaning of previous marks, unless it is stated in the
#   function documentation.
# - @connect["L"|"C"][:from|:to] and @paths_with are hashes of indices of
#   @lines["L"|"C"|"P"] which allow to directly find the links, containments
#   and paths involving a given segment; they must be updated if links,
#   containments or paths are added or deleted
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
    @mark = {"S" => [], "L" => []}
  end

  # Searches for an unbranched_segpath from +from+ to +to+.
  #
  # *Returns*:
  #   - if a segpath exists -> an array of segment names
  #   - otherwise -> +nil+
  def unbranched_segpath(from, to)
    @mark["S"] = []
    segpaths = traverse_unbranched(from, true, store_path: true)
    return segpaths.last == to ? segpaths : nil
  end

  # Searches for an unbranched_segpath from +from+ to +to+.
  #
  # *Raises*
  #   - +RuntimeError+ if no segpath exists
  #
  # *Returns*:
  #   - an array of segment names
  #
  def unbranched_segpath!(from, to)
    usp = unbranched_segpath(from, to)
    raise "No unbranched segment path exists from #{from} to #{to}" if usp.nil?
    return usp
  end

  # Determines the links connectivity of a segment +segment_name+
  #
  # *Returns*:
  #   Let i be the number of incoming links (0,1 or M=multiple)
  #   and o the number of outgoing links (0,1,M).
  #   Then according to [i,o]:
  #   - [0,0] -> +:isolated+
  #   - [1,1] -> +:internal+ if the orientations of the segment in the incoming
  #           and outgoing link are equal; otherwise +:end_11+
  #   - [0,1]/[1,0]/[M,0]/[0,M] -> +:"end_#{i}#{o}"+ (e.g. +:end_01+)
  #   - [1,M]/[M,M]/[M,1] -> +:"junction_#{i}#{o}"+ (e.g. +:junction_M1+)
  #
  def segment_junction_type(segment_name)
    junction_type(links_to(segment_name), links_from(segment_name))
  end

  # Traverse an unbranched segments path from an internal or end segment +from+
  #
  # *Arguments*:
  #   - +from+: the segment from which the traversing is started;
  #           if the segment junction_type is not either :internal or the
  #           appropriate one among +:end_01+ and +:end_10+
  #           (depending on +direct_direction+),
  #           then +nil+ or an empty path is returned
  #   - +direct_direction+: if set, outgoing links are followed, otherwise
  #                         incoming links are followed backwards
  #   - +store_path+: if set, the return value is an array of segment names,
  #                   otherwise only the last element of the path is returned
  # *Returns*:
  #   - if +!store_path+ and a path exists: the last segment name of the path
  #   - if +!store_path+ and no path exists: +nil+
  #   - if +store_path+ and a path exists: an array of segment names
  #   - if +store_path+ and no path exists: +[]+
  #
  def traverse_unbranched(from, direct_direction,
                          store_path: false)
    list = [from] if store_path
    prev_elem = nil
    current_elem = from
    loop do
      flist = links_from(current_elem)
      tlist = links_to(current_elem)
      jt = junction_type(tlist, flist)
      if jt == :internal or
          (prev_elem == nil and
             (direct_direction  and jt == :end_01) or
             (!direct_direction and jt == :end_10))
        prev_elem = current_elem
        current_elem = direct_direction ? flist[0].to : tlist[0].from
        if @mark["S"][@segment_names.index(current_elem)] == :visited
          return store_path ? list : prev_elem
        else
          @mark["S"][@segment_names.index(current_elem)] = :visited
          list << current_elem if store_path
        end
      elsif jt == :end_10 and direct_direction
        return store_path ? list : current_elem
      elsif jt == :end_01 and !direct_direction
        return store_path ? list : current_elem
      else
        return store_path ? list[0..-2] : prev_elem
      end
    end
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
    [:from, :to].each do |d|
      define_method(:"#{c}_#{d}") do |segment_name|
        links_or_containments_for_segment(c[0].upcase, d, segment_name)
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

  private

  # Searches for a link (if +rt == "L"+) or containment (if +rt == "C"+)
  # connecting segments +from+ and +to+. The orientation and starting pos
  # (the latter for containments only) must match only if not +nil+.
  # The first L or C found is returned, +nil+ if nothing matches.
  def link_or_containment(rt, from, from_orient, to, to_orient, pos)
    @connect[rt][:from].fetch(from,[]).each do |li|
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

  # Searches for links (if +rt == "L"+) or containments (if +rt == "C"+)
  # involving segment +segment_name+ as to or from (depending on +direction+).
  # Returns a possibly empty array of matching L or C.
  def links_or_containments_for_segment(rt, direction, segment_name)
    @connect[rt][direction].fetch(segment_name,[]).map{|i|@lines[rt][i]}
  end

  # Determines the links connectivity of a segment based on the list
  # of incoming and outgoing links.
  #
  # *Returns*:
  # - see +segment_junction_type+ return value
  def junction_type(to_list, from_list)
    if from_list.size == 1
      if to_list.size == 1
        if from_list[0].from_orient == to_list[0].to_orient
          return :internal
        else
          return :end_11
        end
      elsif to_list.size == 0
        return :end_01
      else
        return :junction_M1
      end
    elsif from_list.size == 0
      if to_list.size == 1
        return :end_10
      elsif to_list.size == 0
        return :isolated
      else
        return :end_M0
      end
    else # from_list.size > 1
      if to_list.size == 1
        return :junction_1M
      elsif to_list.size == 0
        return :end_0M
      else
        return :junction_MM
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

