import gfapy

class LengthGFA1:

  @property
  def length(self):
    """
    Returns
    -------
    int
      Value of LN tag, if segment has LN tag.
    int
      Sequence length if no LN and sequence not "*".
    None
      If sequence is "*".

    See Also
    --------
    try_get_length
    """
    if self.LN:
      return self.LN
    elif not gfapy.is_placeholder(self.sequence):
      return len(self.sequence)
    else:
      return None

  def try_get_length(self):
    """
    Raises
    ------
    gfapy.NotFoundError
      If not an LN tag and the sequence is "*".

    See Also
    --------
    __len__
    """
    l = self.length
    if l is None:
      raise gfapy.NotFoundError("No length information available")
    return l

  def validate_length(self):
    """
    Raises
    ------
    gfapy.InconsistencyError
      If sequence length and LN tag are not consistent.
    """
    if not gfapy.is_placeholder(self.sequence) and "LN" in self.tagnames:
      if self.LN != len(self.sequence):
        raise gfapy.InconsistencyError(
          "Segment: {}\n".format(str(self))+
          "Length in LN tag ({}) ".format(self.LN)+
          "is different from length of sequence field ({})"
          .format(len(self.sequence)))

  def _validate_record_type_specific_info(self):
    self.validate_length()
