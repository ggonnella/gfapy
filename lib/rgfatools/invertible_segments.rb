#
# Methods which edit the graph components without traversal
#
module RGFATools::InvertibleSegments

  # Selects a random orientation for all invertible segments
  # @return [RGFA] self
  def randomly_orient_invertibles
    segment_names.each do |sn|
      if segment_same_links_both_ends?(sn)
        randomly_orient_proven_invertible_segment(sn)
      end
    end
    self
  end

  # Selects a random orientation for an invertible segment
  # @return [RGFA] self
  # @!macro segment_param
  def randomly_orient_invertible(segment)
    segment_name = segment.kind_of?(RGFA::Line) ? segment.name : segment
    if !segment_same_links_both_ends?(segment_name)
      raise "Only segments with links to the same or equivalent segments "+
              "at both ends can be randomly oriented"
    end
    randomly_orient_proven_invertible_segment(segment_name)
    self
  end

  private

  def randomly_orient_proven_invertible_segment(segment_name)
    parts = partitioned_links_of([segment_name, :E])
    if parts.size == 2
      tokeep1_other_end = parts[0][0].other_end([segment_name, :E])
      tokeep2_other_end = parts[1][0].other_end([segment_name, :E])
    elsif parts.size == 1 and parts[0].size == 2
      tokeep1_other_end = parts[0][0].other_end([segment_name, :E])
      tokeep2_other_end = parts[0][1].other_end([segment_name, :E])
    else
      return
    end
    return if links_of(tokeep1_other_end).size < 2
    return if links_of(tokeep2_other_end).size < 2
    delete_other_links([segment_name, :E], tokeep1_other_end)
    delete_other_links([segment_name, :B], tokeep2_other_end)
    annotate_random_orientation(segment_name)
  end

  def link_targets_for_cmp(segment_end)
    links_of(segment_end).map {|l| l.other_end(segment_end).join}
  end

  def segment_same_links_both_ends?(segment_name)
    e_links = link_targets_for_cmp([segment_name, :E])
    b_links = link_targets_for_cmp([segment_name, :B])
    return e_links == b_links
  end

  def segment_signature(segment_end)
    s = segment!(segment_end[0])
    link_targets_for_cmp(segment_end).join(",")+"\t"+
    link_targets_for_cmp(segment_end.invert_end_type).join(",")+"\t"+
    [:or].map do |field|
      s.send(field)
    end.join("\t")
  end

  def partitioned_links_of(segment_end)
    links_of(segment_end).group_by do |l|
      other_end = l.other_end(segment_end)
      sig = segment_signature(other_end)
      sig
    end.map {|sig, par| par}
  end

  def annotate_random_orientation(segment_name)
    segment = segment!(segment_name)
    n = segment.name.to_s.split("_")
    pairs = 0
    pos = [1, segment.LN]
    if segment.or
      o = segment.or.to_s.split(",")
      if o.size > 2
        while o.last == o.first + "^" or o.last + "^" == o.first
          pairs += 1
          o.pop
          o.shift
        end
      end
      if segment.mp
        pos = [segment.mp[pairs*2], segment.mp[-1-pairs*2]]
      end
    end
    rn = segment.rn
    rn ||= []
    rn += pos
    segment.rn = rn
    n[pairs] = "(" + n[pairs]
    n[-1-pairs] = n[-1-pairs] + ")"
    rename(segment.name, n.join("_"))
  end

end
