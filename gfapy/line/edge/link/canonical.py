class Canonical:

  def is_canonical(self):
    """
    Returns **True** if the link is canonical, **False** otherwise.

    == Definition of canonical link

    A link is canonical if:
    - from != to and from < to (lexicographically); or
    - from == to and at least one of from_orient or to_orient is +

    === Details

    In the special case in which from == to (== s) we have the
    following equivalences:

    s + s + == s - s -
    s - s - == s + s + (same as previous case)
    s + s - == s + s - (equivalent to itself)
    s - s + == s - s + (equivalent to itself)

    Considering the values on the left, the first one can be taken as
    canonical, the second not, because it can be transformed in the first
    one; the other two values are canonical, as they are only equivalent
    to themselves.

    Returns
    -------
    bool
    """
    if self.from_name < self.to_name:
      return True
    elif self.from_name > self.to_name:
      return False
    else:
      return "+" in [self.from_orient, self.to_orient]

  def canonicize(self):
    """
    Returns the unchanged link if the link is canonical,
    otherwise complements the link and returns it.

    .. note::
      The path references are not corrected by this method; therefore
      the method shall be used before the link is embedded in a graph.

    Returns
    -------
    gfapy.line.edge.Link
    	self
    """
    if not self.is_canonical():
      return self.complement()
