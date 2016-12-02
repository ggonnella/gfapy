module RGFA::Line::Edge::Link::Complement

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
  # @return [RGFA::Line::Edge::Link] the inverted link.
  def complement
    l = self.clone
    l.from = to
    l.from_orient = to_orient.invert
    l.to = from
    l.to_orient = from_orient.invert
    l.overlap = overlap.complement
    l
  end

  # Complements the link inplace.
  # The tags are left unchanged.
  #
  # @note The path references are not complemented by this method; therefore
  #   the method shall be used before the link is embedded in a graph.
  #
  # @note This method shall be overridden if custom tags
  #   are defined, which have a ``complementation'' operation which determines
  #   their value in the complement link.
  #
  # @return [RGFA::Line::Edge::Link] self
  def complement!
    tmp = self.from
    self.from = self.to
    self.to = tmp
    tmp = self.from_orient
    self.from_orient = self.to_orient.invert
    self.to_orient = tmp.invert
    self.overlap = self.overlap.complement
    return self
  end

end
