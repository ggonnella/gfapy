import gfapy

class References:
  def _initialize_references(self):
    for snum in [1,2]:
      sid = "sid{}".format(snum)
      orient = self.get(sid).orient
      linesymbol = self.get(sid).line
      s = self._gfa.segment(linesymbol)
      if s is None:
        if self._gfa._segments_first_order:
          raise gfapy.NotFoundError()
        s = gfapy.line.segment.GFA2({"sid" : linesymbol,
                                     "slen" : 1,
                                     "sequence" : "*"},
                                    version = "gfa2",
                                    virtual = True)
        s.connect(self._gfa)
      self._set_existing_field(sid, gfapy.OrientedLine(s,orient),
          set_reference = True)
      s._add_reference(self, self._refkey_for_s(snum))

  def _refkey_for_s(self, snum):
    a = [self.sid1.orient, self.sid2.orient]
    if a == ["+", "+"]:
      return "gaps_R" if (snum == 1) else "gaps_L"
    elif a == ["+", "-"]:
      return "gaps_R"
    elif a == ["-", "+"]:
      return "gaps_L"
    elif a == ["-", "-"]:
      return "gaps_L" if (snum == 1) else "gaps_R"
    else:
      raise gfapy.AssertionError("Bug found, please report\n"+
                                 "snum: {}".format(snum))

  def _import_field_references(self, previous):
    for sid in ["sid1", "sid2"]:
      orient = self.get(sid).orient
      linesymbol = self.get(sid).line
      self._set_existing_field(sid,
          gfapy.OrientedLine(self._gfa.segment(linesymbol),orient),
          set_reference = True)
