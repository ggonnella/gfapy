class OrientedSegments:

  @property
  def oriented_from(self):
    """
    Returns
    -------
    gfapy.OrientedLine
      The oriented segment represented by the from/from_orient fields.
    """
    return gfapy.OrientedLine(self.frm, self.from_orient)

  @property
  def oriented_to(self):
    """
    Returns
    -------
    gfapy.OrientedLine
      The oriented segment represented by the to/to_orient fields.
    """
    return gfapy.OrientedLine(self.to, self.to_orient)
