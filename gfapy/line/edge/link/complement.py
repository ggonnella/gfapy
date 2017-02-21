import gfapy

class Complement:

  def complement(self):
    """
    Creates the equivalent link with from/to inverted.

    The CIGAR operations (order/type) are inverted as well.
    Tags are left unchanged.

    .. note:: The path references are not copied to the complement link.

    .. note::
      This method shall be overridden if custom tags
      are defined, which have a ``complementation'' operation which determines
      their value in the equivalent complement link.

    Returns
    -------
    gfapy.line.edge.Link
    	The inverted link.
    """
    l = self.clone()
    l.from_segment = self.to
    l.from_orient = gfapy.invert(self.to_orient)
    l.to_segment = self.from_segment
    l.to_orient = gfapy.invert(self.from_orient)
    l.overlap = self.overlap.complement()
    return l

  def make_complement(self):
    """
    Complements the link inplace.
    The tags are left unchanged.

    .. note::
      The path references are not complemented by this method; therefore
      the method shall be used before the link is embedded in a graph.

    .. note::
      This method shall be overridden if custom tags
      are defined, which have a ``complementation'' operation which determines
      their value in the complement link.

    Returns
    -------
    gfapy.line.edge.Link
      self
    """
    tmp = self.from_segment
    self.from_segment = self.to_segment
    self.to_segment = tmp
    tmp = self.from_orient
    self.from_orient = gfapy.invert(self.to_orient)
    self.to_orient = gfapy.invert(tmp)
    self.overlap = self.overlap.complement()
    return self