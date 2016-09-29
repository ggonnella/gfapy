class WriterWoSequence:

  def __str__(self, without_sequence = False):
    """
    Parameters
    ----------
    without_sequence : bool
    	 If **True**, output "*" instead of sequence.
    
    Returns
    -------
    str
    	String representation of the segment.
    """
    if not without_sequence:
      return super().__str__()
    else:
      saved = self.sequence
      self.sequence = "*"
      retval = super().__str__()
      self.sequence = saved
      return retval
