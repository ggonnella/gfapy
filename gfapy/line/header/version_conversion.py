class VersionConversion:

  def _to_gfa2_a(self):
    """
    Return the string representation of the tags, changing the value
    of the VN tag to 2.0, if this is present

    Returns
    -------
    list of str
    	Array of strings representing the tags.
    """
    a = ["H"]
    if self.VN:
      a.append("VN:Z:2.0")
    for fn in self.tagnames:
      if fn != "VN":
        a.append(self.field_to_s(fn, tag = True))
    return a

  def _to_gfa1_a(self):
    """
    Return the string representation of the tags, changing the value
    of the VN tag to 1.0, if this is present

    Returns
    -------
    list of str
    	Array of strings representing the tags.
    """
    a = ["H"]
    if self.VN:
      a.append("VN:Z:1.0")
    for fn in self.tagnames:
      if fn != "VN":
        a.append(self.field_to_s(fn, tag = True))
    return a
