RGFA::Line::Edge::GFA1 ||= Module.new

module RGFA::Line::Edge::GFA1::OrientedSegments

  # @return [RGFA::OrientedSegment] the oriented segment represented by the
  #   from/from_orient fields
  def oriented_from
    [from, from_orient].to_oriented_segment
  end

  # @return [RGFA::OrientedSegment] the oriented segment represented by the
  #   to/to_orient fields
  def oriented_to
    [to, to_orient].to_oriented_segment
  end

end
