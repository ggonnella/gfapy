#
# Methods for the GFA class, which involve a traversal of the graph following
# links
#
module GFA::Traverse

  require "set"

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

  # limitations:
  # - all containments und paths involving merged segments are deleted
  def merge_unbranched_segpath!(segment_names)
    raise if segment_names.size < 2
    raise if segment_names[1..-2].any? do |sn|
      segment_junction_type(sn) != :internal
    end
    merged = segment(segment_names[0]).clone
    merged.name = segment_names.join("_")
    merged.sequence = joined_sequences(segment_names)
    sum_of_counts(segment_names).each do |count_tag, count|
      merged.send(:"#{count_tag}=", count)
    end
    l = link(segment_names[0],nil,segment_names[1],nil)
    first_reversed = (l.end_type(segment_names[0]) == :B)
    l = link(segment_names[-2],nil,segment_names[-1],nil)
    last_reversed = (l.end_type(segment_names[-1]) == :E)
    self << merged
    links_of(segment_names.first, nil).each do |l|
      l2 = l.clone
      if l2.to == segment_names.first
        l2.to = merged.name
        if first_reversed
          l2.to_orient = GFA::Line.other_orientation(l2.to_orient)
        end
      else
        l2.from = merged.name
        if first_reversed
          l2.from_orient = GFA::Line.other_orientation(l2.from_orient)
        end
      end
      self << l2
    end
    links_of(segment_names.last, nil).each do |l|
      l2 = l.clone
      if l2.from == segment_names.last
        l2.from = merged.name
        if last_reversed
          l2.from_orient = GFA::Line.other_orientation(l2.from_orient)
        end
      else
        l2.to = merged.name
        if last_reversed
          l2.to_orient = GFA::Line.other_orientation(l2.to_orient)
        end
      end
      self << l2
    end
    segment_names.each {|sn| delete_segment!(sn)}
    self
  end

  def merge_all_unbranched_segpaths!
    paths = unbranched_segpaths
    paths.each {|path| merge_unbranched_segpath!(path)}
    self
  end

  private

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

  def sum_of_counts(segnames)
    retval = {}
    segs = segnames.map {|sn|segment(sn)}
    [:KC, :RC, :FC].each do |count_tag|
      segs.each do |s|
        if s.optional_fieldnames.include?(count_tag)
          retval[count_tag] ||= 0
          retval[count_tag] += s.send(count_tag)
        end
      end
    end
    return retval
  end

  def joined_sequences(segnames)
    retval = ""
    (segnames.size-1).times do |i|
      a = segnames[i]
      b = segnames[i+1]
      l = link!(a, nil, b, nil)
      a = segment!(a)
      b = segment!(b)
      return "*" if a.sequence == "*" or b.sequence == "*"
      if l.overlap == "*"
        cut = 0
      elsif l.overlap.size == 1 and l.overlap[0][1] == "M"
        cut = l.overlap[0][0]
      else
        raise "Overlaps contaning other operations than M are not supported"
      end
      if retval.empty?
        retval << (l.end_type(a.name) == :E ? a.sequence : a.sequence.rc)
      end
      seq = (l.end_type(b.name) == :B ? b.sequence : b.sequence.rc)
      if cut > 0
        raise "Inconsistent overlap" if retval[(-cut)..-1] != seq[0..(cut-1)]
      end
      retval << seq[cut..-1]
    end
    return retval
  end

end
