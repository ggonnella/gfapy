class SegmentEndsPath(list):
  """
  a list containing {gfapy.SegmentEnd} elements, which defines a path
  in the graph
  """

  def reverse(self):
    """
    Reverses the direction of the path in place
    """
    self[:] = list(reversed(self))

  def __reversed__(self):
    """
    Iterator over the reverse-direction path
    """
    for elem in SegmentEndsPath(reversed([segment_end.inverted()
                                for segment_end in self])):
      yield elem
