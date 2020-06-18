import gfapy

class GFA1ToGFA2:

  def _to_gfa2_a(self):
    """
    Returns
    -------
    list of str
    	A list of GFA2 field strings.
    """
    try:
       length = self.try_get_length()
    except gfapy.NotFoundError:
      raise gfapy.RuntimeError(
          "Conversion of GFA1 segment line to GFA2 failed\n"+
          "GFA2 requires to specify a length\n"+
          "No length information available in the GFA1 segment:\n"+
          "Segment line: {}".format(str(self)))
    a = ["S", self.field_to_s("name", tag = False), str(length),
              self.field_to_s("sequence", tag = False)]
    for fn in self.tagnames:
      if fn != "LN":
        a.append(self.field_to_s(fn, tag = True))
    return a
