class Canonical:

  def is_canonical(self):
    """Checks if a link is expressed in the canonical form.

    Returns:
      bool

    Links can be expressed in two different forms. If a link is
    expressed in the other form, it is converted before storing.

    Note:
      A link is considered canonical in Gfapy if either the from segment name
      is lexicographically smaller than the to segment name, or the two segment
      names are equal, and at least one orientation is positive.

    Note:
      In the special case in which from == to (== s) we have the
      following equivalences:

      ::
          s + s + == s - s -
          s - s - == s + s + (same as previous case)
          s + s - == s + s - (equivalent to itself)
          s - s + == s - s + (equivalent to itself)

      Considering the values on the left, the first one can be taken as
      canonical, the second not, because it can be transformed in the first
      one; the other two values are canonical, as they are only equivalent
      to themselves.
    """
    if self.from_name < self.to_name:
      return True
    elif self.from_name > self.to_name:
      return False
    else:
      return "+" in [self.from_orient, self.to_orient]

  def canonicize(self):
    """The link itself if canonical, the complement link otherwise.

    .. note::
      The method shall be only used before the link is connected to
      a Gfa instance.

    Returns:
      gfapy.line.edge.Link
    """
    if not self.is_canonical():
      return self.complement()
    else:
      return self()
