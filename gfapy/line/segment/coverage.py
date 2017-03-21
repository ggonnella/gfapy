import gfapy

class Coverage:

  def coverage(self, count_tag = "RC", unit_length = 1):
    """Compute the coverage from the value a count_tag (RC, KC or FC).

    If unit_length is provided then: count/(length-unit_length+1),
    otherwise: count/length. The latter is a good approximation if
    length >>> unit_length.

    Parameters:
      count_tag (str): integer tag from which the count shall be
        taken (defaults to RC)
      unit_length (int): average length of the sequence which is counted
        (read for RC, fragment for FC, k-mer for KC).

    Returns:
      int : Coverage, if count_tag and length are defined.
      None : Otherwise
    """
    if count_tag in self.tagnames and self.length:
      return (float(self.get(count_tag)))/(self.length - unit_length + 1)
    else:
      return None

  def try_get_coverage(self, count_tag = "RC", unit_length = 1):
    """
    As coverage, but raises an exception if the coverage cannot be computed.
    """
    c = self.coverage(count_tag = count_tag, unit_length = unit_length)
    if c is None:
      self.try_get_length()
      raise gfapy.NotFoundError(
        "Tag {} undefined for segment {}".format(count_tag, self.name))
    else:
      return c
