class SegmentEndsPath(list):
  """
  An list containing {gfapy.SegmentEnd} elements, which defines a path
  in the graph
  """
  def reverse(self):
    """
    Create a reverse direction path

    Returns
    -------
    gfapy.SegmentEndsPath
    """
    return SegmentEndsPath([segment_end.to_segment_end.invert_end_type 
                            for segment_end in self])
