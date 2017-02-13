import gfapy

class Other:

  def other_oriented_segment(self, oriented_segment):
    """
    Parameters
    ----------
    oriented_segment : gfapy.OrientedLine
      One of the two oriented segments of the line.

    Returns
    -------
    gfapy.OrientedLine
      The other oriented segment.

    Raises
    ------
    gfapy.NotFoundError
      If segment_end is not a segment end of the line.
    """
    if (oriented_from == oriented_segment):
      return self.oriented_to()
    elif (oriented_to == oriented_segment):
      return self.oriented_from()
    else:
      raise gfapy.NotFoundError(
        "Oriented segment '{}' not found\n".format(repr(oriented_segment))+
        "Line: {}".format(self))

  def other(self, segment):
    """
    The other segment of a connection line.
    
    Parameters
    ----------
    segment : gfapy.line.segment.GFA1 or str
      Segment name or instance.
    
    Raises
    ------
    gfapy.NotFoundError
      If segment is not involved in the connection.
    
    Returns
    -------
    str
      The name or instance of the other segment of the connection.
      If circular, then **segment**.
    """
    segment_name = str(segment)
    if segment_name == str(self.frm):
      return self.to
    elif segment_name == str(self.to):
      return self.frm
    else:
      raise gfapy.NotFoundError(
        "Line {} does not involve segment {}".format(self, segment_name))
