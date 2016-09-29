class Complement:

  @property
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
    gfapy.Line.Edge.Link
    	The inverted link.
    """
    l = self.clone()
    l.frm = self.to
    l.from_orient = self.to_orient.invert()
    l.to = self.frm
    l.to_orient = self.from_orient.invert()
    l.overlap = self.overlap.complement
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
    gfapy.Line.Edge.Link
      self
    """
    tmp = self.frm
    self.frm = self.to
    self.to = tmp
    tmp = self.from_orient
    self.from_orient = self.to_orient.invert()
    self.to_orient = tmp.invert()
    self.overlap = self.overlap.complement
    return self
