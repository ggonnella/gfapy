import gfapy

class References:

  def _initialize_references(self):
    st1 = self._substring_type(self.beg1, self.end1)[0]
    st2 = self._substring_type(self.beg2, self.end2)[0]
    for snum in [1, 2]:
      sid = "sid{}".format(snum)
      orient = self.get(sid).orient
      s = self._gfa.segment(self.get(sid).line)
      if s is None:
        if self._gfa._segments_first_order:
          raise gfapy.NotFoundError()
        s = gfapy.line.segment.GFA2({"sid" : self.get(sid).line,
                                     "slen" : 1,
                                     "sequence" : "*"},
                                    version = "gfa2",
                                    virtual = True)
        s.connect(self._gfa)
      self._set_existing_field(sid, gfapy.OrientedLine(s, orient),
          set_reference = True)
      s._add_reference(self, self._refkey_for_s(snum, st1, st2))

  def _refkey_for_s(self, snum, st1, st2):
    if st1 == "whole":
      if st2 == "whole":
        return "edges_to_contained" if snum == 1 else "edges_to_containers"
      else:
        return "edges_to_containers" if snum == 1 else "edges_to_contained"
    elif st2 == "whole":
      return "edges_to_containers" if snum == 2 else "edges_to_contained"
    elif self.sid1.orient == self.sid2.orient:
      if (st1 == "pfx" and st2 == "sfx"):
        return "dovetails_L" if snum == 1 else "dovetails_R"
      elif (st1 == "sfx" and st2 == "pfx"):
        return "dovetails_R" if snum == 1 else "dovetails_L"
      else:
        return "internals"
    else:
      if (st1 == "pfx" and st2 == "pfx"):
        return "dovetails_L"
      elif (st1 == "sfx" and st2 == "sfx"):
        return "dovetails_R"
      else:
        return "internals"

  def _import_field_references(self, previous):
    for sid in ["sid1", "sid2"]:
      self._set_existing_field(sid,
          gfapy.OrientedLine(self._gfa.segment(self.get(sid).line),
            self.get(sid).orient),
          set_reference = True)

  def _backreference_keys(self, ref, key_in_ref):
    if ref.record_type == "U":
      return ["sets"]
    elif ref.record_type == "O":
      return ["paths"]
    elif ref.record_type == "S":
      return ["sid1", "sid2"]
    else:
      raise gfapy.AssertionError(
        "Bug found, please report\n"+
        "ref: {}\n".format(ref)+
        "key_in_ref: {}".format(key_in_ref))
