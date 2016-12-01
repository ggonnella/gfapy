RGFA::Line::Edge::GFA1 ||= Module.new

module RGFA::Line::Edge::GFA1::Other

  # @param oriented_segment [RGFA::OrientedLine]
  #   one of the two oriented segments of the line
  # @return [RGFA::OrientedLine] the other oriented segment
  # @raise [RGFA::NotFoundError] if segment_end is not a segment end of the line
  def other_oriented_segment(oriented_segment)
    if (oriented_from == oriented_segment)
      return oriented_to
    elsif (oriented_to == oriented_segment)
      return oriented_from
    else
      raise RGFA::NotFoundError,
        "Oriented segment '#{oriented_segment.inspect}' not found\n"+
        "Line: #{self}"
    end
  end

  # The other segment of a connection line
  # @param segment [RGFA::Line::Segment::GFA1, Symbol] segment name or instance
  # @raise [RGFA::NotFoundError]
  #   if segment is not involved in the connection
  # @return [Symbol] the name or instance of the other segment of the connection
  #   if circular, then +segment+
  def other(segment)
    segment_name = segment.to_sym
    if segment_name == from.to_sym
      to
    elsif segment_name == to.to_sym
      from
    else
      raise RGFA::NotFoundError,
        "Line #{self} does not involve segment #{segment_name}"
    end
  end

end
