class GFA1ToGFA2:

  def _to_gfa2_a(self):
    """
    Returns
    -------
    list of str
    	A list of GFA2 field strings.
    """
    a = ["S", self.field_to_s("name", tag = False), str(self.try_get_length()),
              self.field_to_s("sequence", tag = False)]
    for fn in self.tagnames:
      if fn != "LN":
        a.append(self.field_to_s(fn, tag = True))
    return a
