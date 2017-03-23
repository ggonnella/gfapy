import gfapy

class FromTo:

  def is_circular(self):
    """Does the edge represent an alignment of a segment with itself?

    Returns:
      bool : if the sid1/sid2 (E) or from_segment/to_segment (L/C)
             segments are equal to each other; thereby, the orientations
             are not considered
    """
    return str(self.from_segment) == str(self.to_segment)

  def is_circular_same_end(self):
    """Does the edge represent an alignment of a segment end with itself?

    Returns
      bool : if the edge is a dovetail overlap, for which sid1/sid2 (E) or
        from_segment/to_segment (L) are equal to each other, and the same
        end of the sequence overlaps itself; (note that this kind of edge
        is actually quite meaningless, but can be defined)
    """
    return self.from_end == self.to_end

  @property
  def from_end(self):
    """The segment end corresponding to the from_segment field of L lines.

    Note:
      The result is meaningful only for dovetails overlaps (GFA1 L lines
      or GFA2 E lines representing dovetail overlaps).

    For a L line, the from_orient field is used to compute if the overlap
    involves the left (5') or right (3') end of the from_segment and the
    SegmentEnd end_type property is set accordingly to 'L' or 'R'.  For a E
    line, it is first computed which of the sid1/sid2 corresponds to the
    from_segment field of a L line, then the same computation is done, as for L
    lines.

    Returns:
      gfapy.segment_end.SegmentEnd
    """
    return gfapy.SegmentEnd(self.from_segment,
                            "R" if self.from_orient == "+" else "L")

  @property
  def to_end(self):
    """The segment end corresponding to the to_segment field of L lines.

    Note:
      The result is meaningful only for dovetails overlaps (GFA1 L lines
      or GFA2 E lines representing dovetail overlaps).

    For a L line, the to_orient field is used to compute if the overlap
    involves the left (5') or right (3') end of the to_segment and the
    SegmentEnd end_type property is set accordingly to 'L' or 'R'.  For a E
    line, it is first computed which of the sid1/sid2 corresponds to the
    to_segment field of a L line, then the same computation is done, as for L
    lines.

    Returns:
      gfapy.segment_end.SegmentEnd
    """
    return gfapy.SegmentEnd(self.to_segment,
                            "L" if self.to_orient == "+" else "R")

  def other_end(self, segment_end, tolerant=False):
    """The other segment end involved in the alignment represented by the edge.

    Note:
      The result is meaningful only for dovetails overlaps (GFA1 L lines
      or GFA2 E lines representing dovetail overlaps).

    Parameters:
      segment_end (`gfapy.segment_end.SegmentEnd`) : one of the two segment
        ends involved in the alignment represented by the edge

    Returns:
      gfapy.segment_end.SegmentEnd

    Raises:
      gfapy.error.ArgumentError: If segment_end is not a valid segment end
      gfapy.RuntimeError: if the segment_end is not involved in the alignment
        represented by the line.
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

  @property
  def from_name(self):
    """Segment name of the segment with the role of a L/C from_segment.

   The method allows to compute the segment name in both cases in which
   the segment is a string (i.e. the segment name itself) or a reference
   to a segment line.

    Returns:
      str : the name of the segment which is specified in the field which
        corresponds to the from_segment field in a GFA1 line (from_segment
        if GFA1, sid1 or sid2 if GFA2)
    """
    if isinstance(self.from_segment, str):
      return self.from_segment
    else:
      return self.from_segment.name

  @property
  def to_name(self):
    """Segment name of the segment with the role of a L/C to_segment.

   The method allows to compute the segment name in both cases in which
   the segment is a string (i.e. the segment name itself) or a reference
   to a segment line.

    Returns:
      str : the name of the segment which is specified in the field which
        corresponds to the to_segment field in a GFA1 line (to_segment
        if GFA1, sid1 or sid2 if GFA2)
    """
    if isinstance(self.to_segment, str):
      return self.to_segment
    else:
      return self.to_segment.name

  @property
  def _segment_ends_s(self):
    """Signature of the segment ends, for debugging."""
    return "---".join([str(self.from_end), str(self.to_end)])
