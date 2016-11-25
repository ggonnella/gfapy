RGFA::Line::Edge::GFA1 ||= Module.new

module RGFA::Line::Edge::GFA1::OrientedSegments

  # @return [RGFA::OrientedLine] the oriented segment represented by the
  #   from/from_orient fields
  def oriented_from
    OL[from, from_orient]
  end

  # @return [RGFA::OrientedLine] the oriented segment represented by the
  #   to/to_orient fields
  def oriented_to
    OL[to, to_orient]
  end

end
