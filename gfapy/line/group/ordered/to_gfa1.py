import gfapy

class ToGFA1:

  def _to_gfa1_a(self):
    a = ["P"]
    if gfapy.is_placeholder(self.name):
      raise gfapy.ValueError(
        "Conversion to GFA1 failed\n"+
        "The path name is a placeholder\t"+
        "Line: {}".format(self))
    a.append(self.name)
    segment_names = []
    for oline in self.captured_segments:
      gfapy.Field._validate_gfa_field(oline.name, "segment_name_gfa1")
      segment_names.append(str(oline))
    a.append(",".join(segment_names))
    overlaps = []
    for oline in self.captured_edges:
      gfapy.Field._validate_gfa_field(oline.line.overlap, "alignment_gfa1")
      overlaps.append(str(oline.line.overlap))
    a.append(",".join(overlaps))
    for tn in self.tagnames:
      a.append(self.field_to_s(tn, tag=True))
    return a
