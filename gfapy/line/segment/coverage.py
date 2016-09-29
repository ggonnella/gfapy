import gfapy

class Coverage:

  def coverage(self, count_tag = "RC", unit_length = 1):
    """
    The coverage computed from a count_tag.
    If unit_length is provided then: count/(length-unit_length+1),
    otherwise: count/length.
    The latter is a good approximation if length >>> unit_length.
    
    Parameters
    ----------
    count_tag : str, optional
      *(defaults to ***"RC"***)*
      Integer tag storing the count, usually "KC", "RC" or "FC".
    unit_length : int
      The (average) length of a read (for "RC"), 
      fragment (for "FC") or k-mer (for "KC")
    
    Returns
    -------
    int
      Coverage, if count_tag and length are defined.
    None
      Otherwise

    See Also
    --------
    try_get_coverage
    """
    if count_tag in self.tagnames and self.length:
      return (float(self.get(count_tag)))/(self.length - unit_length + 1)
    else:
      return None

  def try_get_coverage(self, count_tag = "RC", unit_length = 1):
    """
    :meth:`coverage`

    Raises
    ------
    gfapy.NotFoundError
      If segment does not have count_tag.
    """
    c = self.coverage(count_tag = count_tag, unit_length = unit_length)
    if c is None:
      self.try_get_length()
      raise gfapy.NotFoundError(
        "Tag {} undefined for segment {}".format(count_tag, self.name))
    else:
      return c
