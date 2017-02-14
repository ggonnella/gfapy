import gfapy

class ToGFA2:

  def _to_gfa2_a(self):
    items = []
    for oline in self.captured_path:
      if isinstance(oline.line, gfapy.line.segment.GFA1):
        items.append(str(oline))
      elif isinstance(oline.line, gfapy.line.edge.Link):
        eid = oline.line.eid
        if gfapy.is_placeholder(eid):
          raise gfapy.ValueError(
            "Link {} has no identifier\n".format(oline.line)+
            "Path conversion to GFA2 failed")
        items.append(eid + str(oline.orient))
    a = ["O"]
    a.append(self.field_to_s("path_name"))
    a.append(" ".join(items))
    return a
