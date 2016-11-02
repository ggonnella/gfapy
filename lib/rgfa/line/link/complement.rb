module RGFA::Line::Link::Complement

  # Creates the equivalent link with from/to inverted.
  #
  # The CIGAR operations (order/type) are inverted as well.
  # Tags are left unchanged.
  #
  # @note The path references are not copied to the complement link.
  #
  # @note This method shall be overridden if custom tags
  #   are defined, which have a ``complementation'' operation which determines
  #   their value in the equivalent complement link.
  #
  # @return [RGFA::Line::Link] the inverted link.
  def complement
    l = self.clone
    l.from = to
    l.from_orient = (to_orient == :+ ? :- : :+)
    l.to = from
    l.to_orient = (from_orient == :+ ? :- : :+)
    l.overlap = complement_overlap
    l
  end

  # Complements the link inplace, i.e. sets:
  #   from = to
  #   from_orient = other_orient(to_orient)
  #   to = from
  #   to_orient = other_orient(from_orient)
  #   overlap = complement_overlap.
  #
  # The tags are left unchanged.
  #
  # @note The path references are not complemented by this method; therefore
  #   the method shall be used before the link is embedded in a graph.
  #
  # @note This method shall be overridden if custom tags
  #   are defined, which have a ``complementation'' operation which determines
  #   their value in the complement link.
  #
  # @return [RGFA::Line::Link] self
  def complement!
    tmp = self.from
    self.from = self.to
    self.to = tmp
    tmp = self.from_orient
    self.from_orient = (self.to_orient == :+) ? :- : :+
    self.to_orient = (tmp == :+) ? :- : :+
    self.overlap = self.complement_overlap
    return self
  end

  # Compute the overlap when the strand of both sequences is inverted.
  #
  # @return [RGFA::CIGAR, RGFA::Placeholder]
  def complement_overlap
    self.overlap.to_alignment.complement
  end

end
