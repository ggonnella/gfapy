import gfapy

class ToGFA2:
  """
  Methods for the access of / conversion from a GFA1 link/containment
  as / to a GFA2 edge.

  Requirements: **from**, **from_orient**, **to**, **to_orient**,
  **from_coords**, **to_coords**.
  """

  @property
  def name(self):
    i = self.get("ID")
    if i is None:
      return gfapy.Placeholder()
      #i = "{}{} {}{} {}".format(self.from_name(), self.from_orient(),
      #                          self.to_name(), self.to_orient(),
      #                          self.overlap())
    return i

  eid = name
  to_sym = name

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

  def to_gfa2_a(self):
    a = ["E"]
    i = self.get("ID")
    a.append(str(i) if i else "*")
    a.append(str(self.sid1))
    a.append(str(self.sid2))
    a += [ str(x) for x in self.from_cords ]
    a += [ str(x) for x in self.to_coords ]
    a.append(self.field_to_s("overlap"))
    for fn in tagnames:
      if fn != "ID":
        a.append(self.field_to_s(fn, tag = True))
    return a

  def _lastpos_of(self, field):
    if not isinstance(getattr(self,field), gfapy.Line):
      raise gfapy.RuntimeError(
        "Line {} is not embedded in a GFA object".format(self))
    l = len(getattr(self,field))
    if l is None:
      raise gfapy.ValueError(
        "Length of segment {} unknown".format(self.to.name))
    l.to_lastpos

  def _check_overlap(self):
    if isinstance(overlap, gfapy.Placeholder):
      raise gfapy.ValueError(
        "Link: {}\n".format(self)+
        "Missing overlap, cannot compute overlap coordinates")
