module RGFA::Line::Edge::Containment::ToGFA2

  # GFA2 positions of the alignment on the +from+ segment
  # @!macro [new] coords
  #   @return [(Integer|Lastpos,Integer|Lastpos)] begin and end
  #   @raise [RGFA::RuntimeError] if the segment length cannot be determined,
  #     because the segment line is unknown
  #   @raise [RGFA::ValueError] if the segment length is not specified
  #     in the segment line
  def from_coords
    check_overlap
    rpos = pos + overlap.length_on_reference
    rpos = rpos.to_lastpos if rpos == lastpos_of(:from)
    return [pos, rpos]
  end

  # GFA2 positions of the alignment on the +to+ segment
  # @!macro coords
  def to_coords
    return [0, lastpos_of(:to)]
  end

end
