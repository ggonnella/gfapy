class Topology:

  def is_circular(self):
    """
    Is the path circular? In this case the number of CIGARs must be
    equal to the number of segments.

    Returns
    -------
    bool
    """
    return len(self.overlaps) == len(self.segment_names)

  def is_linear(self):
    """
    Is the path linear? This is the case when the number of CIGARs
    is equal to the number of segments minus 1, or the CIGARs are
    represented by a single "*".
    """
    return not self.is_circular()
