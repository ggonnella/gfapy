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

  def circular?
    from == to
  end

end
