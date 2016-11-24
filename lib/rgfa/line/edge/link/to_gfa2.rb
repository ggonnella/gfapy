module RGFA::Line::Edge::Link::ToGFA2

  # GFA2 positions of the alignment on the +from+ segment
  # @!macro [new] coords
  #   @return [(Integer|Lastpos,Integer|Lastpos)] begin and end
  #   @raise [RGFA::ValueError] if the overlap is not specified
  #   @raise [RGFA::RuntimeError] if the segment length cannot be determined,
  #     because the segment line is unknown
  #   @raise [RGFA::ValueError] if the segment length is not specified
  #     in the segment line
  def from_coords
    check_overlap
    if from_orient == :+
      from_l = lastpos_of(:from)
      return [from_l - overlap.length_on_reference, from_l]
    else
      return [0, overlap.length_on_reference]
    end
  end

  # GFA2 positions of the alignment on the +to+ segment
  # @!macro coords
  def to_coords
    check_overlap
    if to_orient == :+
      return [0, overlap.length_on_query]
    else
      to_l = lastpos_of(:to)
      return [to_l - overlap.length_on_query, to_l]
    end
  end

end
