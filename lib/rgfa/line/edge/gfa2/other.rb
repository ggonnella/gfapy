RGFA::Line::Edge::GFA2 ||= Module.new

module RGFA::Line::Edge::GFA2::Other

  # @param oriented_segment [RGFA::OrientedLine]
  #   one of the two oriented segments of the line
  # @return [RGFA::OrientedLine] the other oriented segment
  # @raise [RGFA::NotFoundError] if segment_end is not a segment end of the line
  def other_oriented_segment(oriented_segment)
    if (sid1 == oriented_segment)
      return sid2
    elsif (sid2 == oriented_segment)
      return sid1
    else
      raise RGFA::NotFoundError,
        "Oriented segment '#{oriented_segment}' not found\n"+
        "Line: #{self}"
    end
  end

  # The other segment of a connection line
  # @param segment [RGFA::Line::Segment::GFA2, Symbol] segment name or instance
  # @raise [RGFA::NotFoundError]
  #   if segment is not involved in the connection
  # @return [RGFA::Line::Segment::GFA2, Symbol] the instance or symbol
  #   of the other segment of the connection
  #   (which is the +segment+ itself, when the connection is circular)
  def other(segment)
    segment_name = segment.to_sym
    if segment_name == sid1.name
      sid2.line
    elsif segment_name == sid2.name
      sid1.line
    else
      raise RGFA::NotFoundError,
        "Line #{self} does not involve segment #{segment_name}"
    end
  end

end
