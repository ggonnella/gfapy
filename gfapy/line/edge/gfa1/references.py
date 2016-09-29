class References:
  def _initialize_references(self):
    for dir in ["from", "to"]:
      s = self.gfa.segment(self.get(dir))
      if s is None: 
        if self.gfa.segments_first_order():
          raise gfapy.NotFoundError()
        s = gfapy.Line.Segment.GFA1({"name" : self.get(dir),
                                     "sequence" : "*"},
                                    version = "gfa1",
                                    virtual = True)
        s.connect(self.gfa)
      self.set_existing_field(dir, s, set_reference = True)
      if self.record_type == "L":
        et = send("{}_end".format(dir)).end_type
        key = "dovetails_{}".format(et)
      else:
        key = \
          "edges_to_contained" if (dir == "from") else "edges_to_containers"
      s.add_reference(self, key)

  def _import_field_references(self, previous):
    for dir in ["from", "to"]:
      self.set_existing_field(dir, self.gfa.segment(self.get(dir)), set_reference = True)

  def _backreference_keys(self, ref, key_in_ref):
    if ref.record_type == "P":
      return ["paths"]
    elif ref.record_type == "S":
      return ["from", "to"]
    else:
      return []
