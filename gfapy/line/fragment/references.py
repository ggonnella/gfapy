import gfapy

class References():

  def _initialize_references(self):
    s = self._gfa.segment(self.get("sid"))
    if s is None:
      if self._gfa._segments_first_order:
        raise gfapy.NotFoundError()
      s = gfapy.line.segment.GFA2({"sid": self.get("sid"),
                                   "slen": 1,
                                   "sequence": "*"},
                                   version = "gfa2",
                                   virtual = True)
      s.connect(self._gfa)
    self._set_existing_field("sid", s, set_reference = True)
    s._add_reference(self, "fragments")
