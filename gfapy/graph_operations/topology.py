import gfapy

class Topology:

  def is_cut_link(self, link):
    if link.is_circular:
      return False
    if not link.from.dovetails(link.from_end.end_type.invert()):
      return True
    if not link.to.dovetails(link.to_end.end_type.invert()):
      return True
    c = {}
    for et in ["from", "to"]:
      c[et] = set()
      visited = set()
      segend = link.from if et == "from" else link.to
      visited.append(segend.name)
      visited.append(link.other_end(segend).name)
      self.__traverse_component(segend, c[et], visited)
    return c["from"] != c["to"]

  def is_cut_segment(self, segment):
    if isinstance(segment, str):
      segment = self.try_get_segment(segment)
    if segment.connectivity in [(0,0),(0,1),(1,0)]:
      return False
    start_points = set()
    for et in ["L", "R"]:
      for l in segment.dovetails(et):
        start_points.append(l.other_end(\
            gfapy.SegmentEnd(segment_name, et)).invert())
    cc = []
    for start_point in start_points:
      cc.append(set())
      visited = set()
      visited.append(segment_name)
      traverse_component(start_point, cc[-1], visited)
    return any(c != cc[0] for c in cc)


  def segment_connected_component(self, segment, visited = None):
    if visited is None:
      visited = set()
    if not isinstance(segment, str):
      segment = segment.name
    visited.append(segment)
    c = [segment]
    for e in ["L", "R"]:
      self.__traverse_component(gfapy.SegmentEnd(sn, e), c, visited)
    return c

  @property
  def connected_components(self):
    components = []
    visited = set()
    for sn in segment_names:
      if sn not in visited:
        components.append(segment_connected_component(sn, visited))
    return components

  def split_connected_components(self):
    retval = []
    for cc in self.connected_components:
      gfa2 = self.clone
      gfa2.rm(gfa2.segment_names - cc)
      retval.append(gfa2)
    return retval

  @property
  def n_dead_ends(self):
    n = 0
    for s in self.segments:
      if not s.dovetails_L: n+=1
      if not s.dovetails_R: n+=1
    return n

  @property
  def n_dovetails(self):
    n = 0
    for s in self.segments:
      n += len(s.dovetails_L)
      n += len(s.dovetails_R)
    return n // 2

  @property
  def n_internals(self):
    n = 0
    for s in self.segments:
      n += len(s.internals)
    return n // 2

  @property
  def n_containments(self):
    n = 0
    for s in self.segments:
      n += len(s.edges_to_contained)
      n += len(s.edges_to_containers)
    return n // 2

  def info(self, short):
    pass

  def __traverse_component(self, segment_end, c, visited):
    s = segment_end.segment
    for l in s.dovetails(segment_end.end_type):
      oe = l.other_end(segment_end)
      sn = oe.name
      if sn in visited:
        next
      visited.append(sn)
      c.append(sn)
      for e in ["L","R"]:
        traverse_component(gfapy.SegmentEnd(sn, e), c, visited)
