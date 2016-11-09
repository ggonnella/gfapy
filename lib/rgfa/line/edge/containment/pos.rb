module RGFA::Line::Edge::Containment::Pos

  # Computes the rightmost coordinate of the contained sequence in the container
  # @return [Integer] 0-based right coordinate of contained in container
  # @raise [RGFA::ValueError] if the overlap is not a CIGAR string
  def rpos
    raise RGFA::ValueError if overlap.kind_of?(RGFA::Placeholder)
    pos + overlap.length_on_reference
  end

end
