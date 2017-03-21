import gfapy

class FromTo:
  """
  Methods regarding the ends (from/to) of a GFA1 link/containment

  Requirements: **from**, **from_orient**, **to**, **to_orient**.
  """

  def is_circular(self):
    """
    Returns
    -------
    bool
      If the from and to segments are equal.
    """
    return str(self.from_segment) == str(self.to_segment)

  def is_circular_same_end(self):
    """
    Returns
    -------
    bool
      If the from and to segments are equal.
    """
    return self.from_end == self.to_end

  @property
  def from_end(self):
    """
    Returns
    -------
    gfapy.SegmentEnd
      The segment end represented by the from/from_orient fields.

    .. note:: The result is meaningful only for links and dovetails edges.
    """
    return gfapy.SegmentEnd.from_list([
                                  self.from_segment,
                                  "R" if self.from_orient == "+" else "L"])

  @property
  def to_end(self):
    """
    Returns
    -------
    gfapy.SegmentEnd
      The segment end represented by the to/to_orient fields.

    .. note:: The result is meaningful only for links and dovetails edges.
    """
    return gfapy.SegmentEnd.from_list([self.to_segment,
      "L" if self.to_orient == "+" else "R"])

  @property
  def segment_ends_s(self):
    """
    Signature of the segment ends, for debugging.
    """
    return "---".join([str(self.from_end), str(self.to_end)])

  @property
  def from_name(self):
    """
    The from segment name, in both cases where from is a segment name (String)
    or a segment (gfapy.line.segment.GFA1)

    Returns
    -------
    str
    """
    if isinstance(self.from_segment, str):
      return self.from_segment
    else:
      return self.from_segment.name

  @property
  def to_name(self):
    """
    The to segment name, in both cases where to is a segment name (String)
    or a segment (gfapy.line.segment.GFA1).

    Returns
    -------
    str
    """
    if isinstance(self.to_segment, str):
      return self.to_segment
    else:
      return self.to_segment.name

  def other_end(self, segment_end, tolerant=False):
    """
    Parameters
    ----------
    segment_end : gfapy.SegmentEnd
      One of the two segment ends of the line.

    Returns
    -------
    gfapy.SegmentEnd
      The other segment end.

    Raises
    ------
    gfapy.ArgumentError
      If segment_end is not a valid segment end representation.
    gfapy.RuntimeError
      If segment_end is not a segment end of the line.

    .. note:: The result is meaningful only for links and dovetails edges.
    """
    segment_end
    if (self.from_end == segment_end):
      return self.to_end
    elif (self.to_end == segment_end):
      return self.from_end
    elif tolerant:
      return None
    else:
      raise gfapy.ArgumentError(
        "Segment end '{}' not found\n".format(repr(segment_end))+
        "(from={};to={})".format(repr(self.from_end), repr(self.to_end)))
