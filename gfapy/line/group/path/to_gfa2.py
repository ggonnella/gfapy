import gfapy

class ToGFA2:

  def _to_gfa2_a(self):
    items = []
    for oline in self.captured_path:
      if isinstance(oline.line, gfapy.line.segment.GFA1):
        items.append(str(oline))
      elif isinstance(oline.line, gfapy.line.edge.Link):
        items.append(oline.line.eid + str(oline.orient))
    a = ["O"]
    a.append(self.field_to_s("path_name"))
    a.append(" ".join(items))
    for tn in self.tagnames:
      a.append(self.field_to_s(tn, tag=True))
    return a
