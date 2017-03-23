import gfapy

class GFA2ToGFA1:

  def _to_gfa1_a(self,
                 slen_tag_if_sequence = "sl",
                 slen_tag_if_no_sequence = "LN"):
    """
    Notes
    -----
    If a sequence is provided, a custom tag (default sl) is used for storing the
    content of the slen field and not LN, as LN _must_ be equal to the length
    of the sequence (if this is specified), but slen must not.
    If no sequence is provided, then LN is used (by default).

    Returns
    -------
    str list
      A array of GFA1 field strings.
    """
    a = ["S", self.field_to_s("name", tag = False),
              self.field_to_s("sequence", tag = False)]
    if gfapy.is_placeholder(self.sequence):
      slen_tag = slen_tag_if_no_sequence
    else:
      slen_tag = slen_tag_if_sequence
    a.append(gfapy.Field._to_gfa_tag(self.slen, slen_tag, datatype = "i"))
    for fn in self.tagnames:
      a.append(self.field_to_s(fn, tag = True))
    return a
