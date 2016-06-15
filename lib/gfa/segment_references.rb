# Methods common to links and containments in their references to segments
module GFA::SegmentReferences

  # The other segment of a link/containment
  # @param segment [String, GFA::Line::Segment] segment name or instance
  # @raise if segment is not involved in link/containment
  # @return [String] the name of the other segment of link/containment;
  #   if circular, then +segment+
  def other(segment)
    segment_name =
      (segment.kind_of?(GFA::Line::Segment) ? segment.name : segment)
    if segment_name == from
      to
    elsif segment_name == to
      from
    else
      raise "Link #{self} does not involve segment #{segment_name}"
    end
  end

  # @return [Boolean] is the from segment of the link/containment
  #   the same as the to segment?
  def circular?
    from == to
  end

end
