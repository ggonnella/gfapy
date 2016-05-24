module GFA::SegmentReferences

  def other(segment_name)
    if segment_name == from
      to
    elsif segment_name == to
      from
    else
      raise "Link #{self} does not involve segment #{segment_name}"
    end
  end

  def orient(segment_name)
    if segment_name == from
      from_orient
    elsif segment_name == to
      to_orient
    else
      raise "Link #{self} does not involve segment #{segment_name}"
    end
  end

  def other_orient(segment_name)
    orient(other(segment_name))
  end

end
