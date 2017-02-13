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
    if (self.sid1 == oriented_segment):
      return self.sid2
    elif (self.sid2 == oriented_segment):
      return self.sid1
    else:
      raise gfapy.NotFoundError(
          "Oriented segment '{}' not found\n".format(oriented_segment) +
          "Line: {}".format(self))

  def other(self, segment):
    """
    The other segment of a connection line.

    Parameters
    ----------
    segment : gfapy.line.segment.GFA2
      Segment name or instance.

    Raises
    ------
    gfapy.NotFoundError
      If segment is not involved in the connection.

    Returns
    -------
    gfapy.Line::Segment::GFA2, Symbol
      The instance or symbol of the other segment of the connection.
      (which is the **segment** itself, when the connection is circular)
    """
    segment_name = str(segment)
    if segment_name == self.sid1.name:
      return sid2.line
    elif segment_name == self.sid2.name:
      return sid1.line
    else:
      raise gfapy.NotFoundError(
        "Line {} does not involve segment {}".format(self, segment_name))
