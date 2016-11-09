module RGFA::Line::Edge::Link::Canonical

  # Returns true if the link is canonical, false otherwise
  #
  # == Definition of canonical link
  #
  # A link if canonical if:
  # - from != to and from < to (lexicographically); or
  # - from == to and at least one of from_orient or to_orient is +
  #
  # === Details
  #
  # In the special case in which from == to (== s) we have the
  # following equivalences:
  #
  #   s + s + == s - s -
  #   s - s - == s + s + (same as previous case)
  #   s + s - == s + s - (equivalent to itself)
  #   s - s + == s - s + (equivalent to itself)
  #
  # Considering the values on the left, the first one can be taken as
  # canonical, the second not, because it can be transformed in the first
  # one; the other two values are canonical, as they are only equivalent
  # to themselves.
  #
  # @return [Boolean]
  #
  def canonical?
    if from_name < to_name
      return true
    elsif from_name > to_name
      return false
    else
      return [from_orient, to_orient].include?(:+)
    end
  end

  # Returns the unchanged link if the link is canonical,
  # otherwise complements the link and returns it.
  #
  # @note The path references are not corrected by this method; therefore
  #   the method shall be used before the link is embedded in a graph.
  #
  # @return [RGFA::Line::Edge::Link] self
  def canonicize!
    complement! if !canonical?
  end

end
