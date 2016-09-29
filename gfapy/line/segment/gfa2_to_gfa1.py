class GFA2ToGFA1:

  def to_gfa1_a(self):
    """
    Returns
    -------
    str list
      A array of GFA1 field strings.
    """
    a = ["S", field_to_s("name", tag = False),
              field_to_s("sequence", tag = False)]
    a.append(self.slen().to_gfa_field(datatype = "i", fieldname = "LN"))
    for fn in self.tagnames:
      a.append(self.field_to_s(fn, tag = True))
    return a
