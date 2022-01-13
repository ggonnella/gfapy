import gfapy

class ToGFA2:

  @property
  def from_coords(self):
    """
    GFA2 positions of the alignment on the **from** segment.

    Returns
    -------
    (Integer|Lastpos, Integer|Lastpos)
    	begin and end

    Raises
    ------
    gfapy.RuntimeError
    	If the segment length cannot be determined, because the segment line is unknown.
    gfapy.ValueError
    	If the segment length is not specified in the segment line.
    """
    self._check_overlap()
    rpos = self.pos + self.overlap.length_on_reference()
    if rpos == self._lastpos_of("from_segment"):
      rpos = gfapy.LastPos(rpos)
    return [self.pos, rpos]

  @property
  def to_coords(self):
    """
    GFA2 positions of the alignment on the **to** segment
    """
    return [0, self._lastpos_of("to_segment")]
