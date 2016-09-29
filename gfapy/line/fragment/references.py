class References():

  def _initialize_references(self):
    s = self.gfa.segment(get("sid"))
    if s is None:
      if self.gfa.segments_first_order():
        raise gfapy.NotFoundError()
      s = gfapy.Line.Segment.GFA2({"sid" : self.get(sid),
                                   "slen" : 1,
                                   "sequence" : "*"},
                                   version = "gfa2",
                                   virtual = True)
      s.connect(self.gfa)
    self.set_existing_field("sid", s, set_reference = True)
    s.add_reference(self, "fragments")
