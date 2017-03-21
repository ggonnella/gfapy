import gfapy

class Other:

  def other_oriented_segment(self, oriented_segment):
    """The other oriented segment.

    Parameters:
      oriented_segment (gfapy.OrientedLine) : One of the two oriented segments of the line.

    Returns:
      gfapy.OrientedLine

    Raises:
      gfapy.error.NotFoundError: If segment_end is not a segment end of the line.
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
    """The other segment of an edge line.

    Parameters:
      segment (gfapy.line.segment.GFA2) : Segment name or instance.

    Raises:
      gfapy.error.NotFoundError: If segment is not a segment of the line.

    Returns:
      gfapy.line.segment.GFA2 or str : instance or name of the other segment
        of the connection (the segment itself, if the connection is circular)
    """
    if isinstance(segment, gfapy.Line):
      segment = segment.name
    if segment == self.sid1.name:
      return self.sid2.line
    elif segment == self.sid2.name:
      return self.sid1.line
    else:
      raise gfapy.NotFoundError(
        "Line {} does not involve segment {}".format(self, segment))
