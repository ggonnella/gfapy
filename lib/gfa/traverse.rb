#
# Methods for the GFA class, which involve a traversal of the graph following
# links
#
module GFA::Traverse

  require "set"

  # Computes the connectivity of a segment from its number of links.
  #
  # *Arguments*:
  #   - +segment_name+: name of the segment
  #   - +reverse_complement+ use the reverse complement of the segment sequence
  #
  # *Returns*:
  #   - [b, e], where:
  #      - bn is the number of links to the beginning of the sequence
  #      - en is the number of links to the end of the sequence
  #      - b = :M if bn > 1, otherwise bn
  #      - e = :M if en > 1, otherwise en
  #
  def connectivity(segment_name, reverse_complement = false)
    ends = [:B, :E]
    ends.reverse! if reverse_complement
    connectivity_symbols(links_of(segment_name, ends.first).size,
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
    cs = connectivity(segment_name)
    case cs
    when [1,1]
      exclude << segment_name
      segpath = traverse_unbranched(segment_name, false, exclude).reverse +
                traverse_unbranched(segment_name, true, exclude)[1..-1]
    when [:M, 1], [0, 1]
      exclude << segment_name
      segpath = traverse_unbranched(segment_name, true, exclude)
    when [1, :M], [1, 0]
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
  def merge_unbranched_segpath(segment_names)
    raise if segment_names.size < 2
    raise if segment_names[1..-2].any? {|sn| connectivity(sn) != [1,1]}
    merged = segment(segment_names[0]).clone
    s, ln, cut, merged_name = joined_sequences(segment_names)
    merged.name = merged_name
    merged.sequence = s
    merged.LN = ln if merged.optional_fieldnames.include?(:LN)
    sum_of_counts(segment_names, ln.to_f/(cut+ln)).each do |count_tag, count|
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
    segment_names.each {|sn| delete_segment(sn)}
    self
  end

  def merge_all_unbranched_segpaths
    paths = unbranched_segpaths
    paths.each {|path| merge_unbranched_segpath(path)}
    self
  end

  def connected_components
    visited = Set.new
    components = []
    segments.map(&:name).each do |sn|
      if visited.include?(sn)
        next
      else
        visited << sn
        c = [sn]
        traverse_component(sn, :B, c, visited)
        traverse_component(sn, :E, c, visited)
        components << c
      end
    end
    return components
  end

  private

  def traverse_component(segment_name, end_type, c, visited)
    links_of(segment_name, end_type).each do |l|
      sn = l.other(segment_name)
      if visited.include?(sn)
        next
      else
        visited << sn
        c << sn
        traverse_component(sn, :B, c, visited)
        traverse_component(sn, :E, c, visited)
      end
    end
  end

  def connectivity_symbols(n,m)
    [connectivity_symbol(n), connectivity_symbol(m)]
  end

  def connectivity_symbol(n)
    n > 1 ? :M : n
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
      cs = connectivity_symbols(before.size, after.size)
      if cs == [1,1] or list.empty?
        list << current_elem
        l = after.first
        current_elem = l.other(current_elem)
        traverse_from_E_end = (l.end_type(current_elem) == :B)
        return list if exclude.include?(current_elem)
        exclude << current_elem
      elsif cs[0] == 1
        list << current_elem
        return list
      else
        return list
      end
    end
  end

  def sum_of_counts(segnames, multfactor = 1)
    retval = {}
    segs = segnames.map {|sn|segment(sn)}
    [:KC, :RC, :FC].each do |count_tag|
      segs.each do |s|
        if s.optional_fieldnames.include?(count_tag)
          retval[count_tag] ||= 0
          retval[count_tag] += s.send(count_tag)
        end
      end
      if retval[count_tag]
        retval[count_tag] = (retval[count_tag] * multfactor).to_i
      end
    end
    return retval
  end

  def joined_sequences(segnames)
    sequence = ""
    ln = 0
    total_cut = 0
    merged_name = ""
    (segnames.size-1).times do |i|
      a = segnames[i]
      b = segnames[i+1]
      l = link!(a, nil, b, nil)
      a = segment!(a)
      b = segment!(b)
      if i == 0
        if l.end_type(a.name) == :E
          sequence = a.sequence
          merged_name = "#{a.name}"
        else
          sequence = a.sequence.rc
          merged_name = "#{a.name}R"
        end
        ln = a.optional_fieldnames.include?(:LN) ? a.LN : nil
      end
      sequence = "*" if b.sequence == "*"
      if l.overlap == "*"
        cut = 0
      elsif l.overlap.size == 1 and l.overlap[0][1] == "M"
        cut = l.overlap[0][0]
      else
        raise "Overlaps contaning other operations than M are not supported"
      end
      total_cut += cut
      if b.optional_fieldnames.include?(:LN) and !ln.nil?
        ln += (b.LN - cut)
      end
      if l.end_type(b.name) == :B
        bseq = b.sequence
        merged_name += "_#{b.name}"
      else
        bseq = b.sequence.rc
        merged_name += "_#{b.name}R"
      end
      if sequence != "*"
        if cut > 0 and sequence[(-cut)..-1] != bseq[0..(cut-1)]
          raise "Inconsistent overlap"
        end
        sequence << bseq[cut..-1]
      end
    end
    if !ln.nil? and ln != sequence.length
      raise "Computed sequence length and computed LN differ"
    end
    ln = sequence.length if ln.nil?
    return sequence, ln, total_cut, merged_name
  end

end
