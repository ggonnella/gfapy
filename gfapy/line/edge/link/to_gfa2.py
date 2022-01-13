class ToGFA2:

  @property
  def from_coords(self):
    """GFA2 positions of the alignment on the **from** segment.

    Returns
    -------
    (Integer|Lastpos,Integer|Lastpos)
    	begin and end

    Raises
    ------
    gfapy.ValueError
    	If the overlap is not specified.
    gfapy.RuntimeError
    	If the segment length cannot be determined, because the segment line is unknown.
    gfapy.ValueError
    	If the segment length is not specified in the segment line.
    """
    self._check_overlap()
    if self.from_orient == "+":
      from_l = self._lastpos_of("from_segment")
      return [from_l - self.overlap.length_on_reference(), from_l]
    else:
      return [0, self.overlap.length_on_reference()]

  @property
  def to_coords(self):
    """GFA2 positions of the alignment on the **to** segment."""
    self._check_overlap()
    if self.to_orient == "+":
      return [0, self.overlap.length_on_query()]
    else:
      to_l = self._lastpos_of("to_segment")
      return [to_l - self.overlap.length_on_query(), to_l]
