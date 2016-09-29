class ToGFA2:

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
    self.check_overlap()
    rpos = self.pos() + self.overlap().length_on_reference()
    if rpos == self.lastpos_of("from"):
      rpos = rpos.to_lastpos() 
    return [self.pos(), rpos]

  def to_coords(self):
    """
    GFA2 positions of the alignment on the **to** segment
    """
    return [0, self.lastpos_of("to")]
