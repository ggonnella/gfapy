import gfapy

class ToGFA2:
  """
  Access of / conversion from a GFA1 link/containment as / to a GFA2 edge.
  """

  @property
  def eid(self):
    """The content of the ID tag"""
    i = self.get("ID")
    if i is None:
      return gfapy.Placeholder()
    return i

  name = eid

  @property
  def sid1(self):
    """The combination of the from_segment and from_orientation fields"""
    return self.oriented_from

  @property
  def sid2(self):
    """The combination of the to_segment and to_orientation fields"""
    return self.oriented_to

  @property
  def beg1(self):
    """The start coordinate of the alignment on the from segment"""
    return self.from_coords[0]

  @property
  def end1(self):
    """The end coordinate of the alignment on the from segment"""
    return self.from_coords[1]

  @property
  def beg2(self):
    """The start coordinate of the alignment on the to segment"""
    return self.to_coords[1]

  @property
  def end2(self):
    """The end coordinate of the alignment on the to segment"""
    return self.to_coords[1]

  @property
  def alignment(self):
    """The content of the overlap field (CIGAR or Placeholder)"""
    return self.overlap

  def _to_gfa2_a(self):
    a = ["E"]
    if not self.get("ID") and self.is_connected():
      self.set("ID", self._gfa.unused_name())
    if self.get("ID"):
      a.append(str(self.get("ID")))
    else:
      a.append("*")
    a.append(str(self.sid1))
    a.append(str(self.sid2))
    a += [ str(x) for x in self.from_coords ]
    a += [ str(x) for x in self.to_coords ]
    try:
      self.overlap.validate(version = "gfa2")
    except:
      raise gfapy.RuntimeError(
        "Conversion of edge line from GFA1 to GFA2 failed\n"+
        "Overlap is invalid or not compatible with GFA2\n"+
        "Edge line: {}\n".format(str(self)))
    a.append(self.field_to_s("overlap"))
    for fn in self.tagnames:
      if fn != "ID":
        a.append(self.field_to_s(fn, tag = True))
    return a

  def _lastpos_of(self, field):
    line = getattr(self,field)
    if not isinstance(line, gfapy.Line):
      raise gfapy.RuntimeError(
        "Line {} is not embedded in a GFA object".format(self))
    length = line.length
    if length is None:
      raise gfapy.ValueError(
        "Length of segment {} unknown".format(self.to_segment.name))
    return gfapy.LastPos(length)

  def _check_overlap(self):
    if isinstance(self.overlap, gfapy.Placeholder):
      raise gfapy.ValueError(
        "Link: {}\n".format(self)+
        "Missing overlap, cannot compute overlap coordinates")
