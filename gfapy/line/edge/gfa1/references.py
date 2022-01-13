import gfapy

class References:
  def _initialize_references(self):
    for d in ["from_segment", "to_segment"]:
      s = self._gfa.segment(self.get(d))
      if s is None:
        if self._gfa._segments_first_order:
          raise gfapy.NotFoundError()
        s = gfapy.line.segment.GFA1({"name" : self.get(d),
                                     "sequence" : "*"},
                                    version = "gfa1",
                                    virtual = True)
        s.connect(self._gfa)
      self._set_existing_field(d, s, set_reference = True)
      if self.record_type == "L":
        et = self.from_end.end_type \
            if d == "from_segment" else self.to_end.end_type
        key = "dovetails_{}".format(et)
      else:
        key = "edges_to_contained" if (d == "from_segment") \
              else "edges_to_containers"
      s._add_reference(self, key)

  def _import_field_references(self, previous):
    for d in ["from_segment", "to_segment"]:
      self._set_existing_field(d, self._gfa.segment(self.get(d)),
          set_reference = True)

  def _backreference_keys(self, ref, key_in_ref):
    if ref.record_type == "P":
      return ["paths"]
    elif ref.record_type == "S":
      return ["from_segment", "to_segment"]
    else:
      return []
