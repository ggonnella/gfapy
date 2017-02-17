import gfapy

class OrientedSegments:

  @property
  def oriented_from(self):
    """
    Returns
    -------
    gfapy.OrientedLine
      The oriented segment represented by the from_segment/from_orient fields.
    """
    return gfapy.OrientedLine(self.from_segment, self.from_orient)

  @property
  def oriented_to(self):
    """
    Returns
    -------
    gfapy.OrientedLine
      The oriented segment represented by the to_segment/to_orient fields.
    """
    return gfapy.OrientedLine(self.to_segment, self.to_orient)
