import gfapy

class GFA2ToGFA1:

  def _to_gfa1_a(self):
    """
    Returns
    -------
    str list
      A array of GFA1 field strings.
    """
    a = ["S", self.field_to_s("name", tag = False),
              self.field_to_s("sequence", tag = False)]
    a.append(gfapy.Field.to_gfa_tag(self.slen, "LN", datatype = "i"))
    for fn in self.tagnames:
      a.append(self.field_to_s(fn, tag = True))
    return a
