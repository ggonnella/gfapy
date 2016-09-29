class Pos:

  def rpos(self):
    """
    Computes the rightmost coordinate of the contained sequence in the container

    Returns
    -------
    int
    	0-based right coordinate of contained in container.

    Raises
    ------
    gfapy.ValueError
    	If the overlap is not a CIGAR string.
    """ 
    if isinstance(self.overlap(), gfapy.Placeholder):
      raise gfapy.ValueError()
    return self.pos() + self.overlap().length_on_reference
