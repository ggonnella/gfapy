import gfapy

class ToGFA2:
  """
  Methods for the access of / conversion from a GFA1 link/containment
  as / to a GFA2 edge.

  Requirements: **from**, **from_orient**, **to**, **to_orient**,
  **from_coords**, **to_coords**.
  """

  @property
  def eid(self):
    i = self.get("id")
    if i is None:
      return gfapy.Placeholder()
      #i = "{}{} {}{} {}".format(self.from_name(), self.from_orient(),
      #                          self.to_name(), self.to_orient(),
      #                          self.overlap())
    return i

  name = eid

  @property
  def sid1(self):
    return self.oriented_from

  @property
  def sid2(self):
    return self.oriented_to

  @property
  def beg1(self):
    return self.from_coords[0]

  @property
  def end1(self):
    return self.from_coords[1]

  @property
  def beg2(self):
    return self.to_coords[1]

  @property
  def end2(self):
    return self.to_coords[1]

  @property
  def alignment(self):
    return self.overlap

  def _to_gfa2_a(self):
    a = ["E"]
    i = self.get("id")
    a.append(str(i) if i else "*")
    a.append(str(self.sid1))
    a.append(str(self.sid2))
    a += [ str(x) for x in self.from_coords ]
    a += [ str(x) for x in self.to_coords ]
    a.append(self.field_to_s("overlap"))
    for fn in self.tagnames:
      if fn != "id":
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
        "Length of segment {} unknown".format(self.to.name))
    return gfapy.LastPos(length)

  def _check_overlap(self):
    if isinstance(self.overlap, gfapy.Placeholder):
      raise gfapy.ValueError(
        "Link: {}\n".format(self)+
        "Missing overlap, cannot compute overlap coordinates")
