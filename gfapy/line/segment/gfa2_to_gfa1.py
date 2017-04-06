import gfapy

class GFA2ToGFA1:

  def _to_gfa1_a(self, slen_tag = "LN"):
    """
    Notes:
      According to the GFA2 specification, slen must be not be really the length
      of the sequence. By default, this is ignored, and the content of slen is
      stored in the LN tag.

    Parameters:
      slen_tag (str) : tag to use in GFA1 to store the content of slen

    Returns:
      str list : A array of GFA1 field strings.
    """
    a = ["S", self.field_to_s("name", tag = False),
              self.field_to_s("sequence", tag = False)]
    a.append(gfapy.Field._to_gfa_tag(self.slen, slen_tag, datatype = "i"))
    for fn in self.tagnames:
      a.append(self.field_to_s(fn, tag = True))
    return a
