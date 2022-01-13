import gfapy

class Topology:

  def is_cut_link(self, link):
    """Does the removal of a dovetail overlap split a connected component?

    Note:
      only dovetail overlaps are considered as connections

    Parameters:
      link (Line) : an edge instance, which represents a dovetail overlap

    Returns:
       bool
    """
    if link.is_circular():
      return False
    if not link.get("from_segment").dovetails_of_end(\
             gfapy.invert(link.from_end.end_type)):
      return True
    if not link.to_segment.dovetails_of_end(gfapy.invert(link.to_end.end_type)):
      return True
    c = {}
    for et in ["from", "to"]:
      c[et] = set()
      visited = set()
      segend = link.get("from_segment") if et == "from" else link.to_segment
      visited.add(segend.name)
      visited.add(link.other_end(segend).name)
      self.__traverse_component(segend, c[et], visited)
    return c["from"] != c["to"]

  def is_cut_segment(self, segment):
    """Does the removal of a segment split a connected component?

    Note:
      only dovetail overlaps are considered as connections

    Parameters:
      segment (str, Line) : a segment name or instance

    Returns:
       bool
    """
    if isinstance(segment, str):
      segment = self.try_get_segment(segment)
    if segment._connectivity() in [(0,0),(0,1),(1,0)]:
      return False
    start_points = set()
    for et in ["L", "R"]:
      for l in segment.dovetails_of_end(et):
        start_points.add(l.other_end(\
            gfapy.SegmentEnd(segment.name, et)).inverted())
    cc = []
    for start_point in start_points:
      cc.append(set())
      visited = set()
      visited.add(segment.name)
      self.__traverse_component(start_point, cc[-1], visited)
    return any(c != cc[0] for c in cc)

  def segment_connected_component(self, segment, visited = None):
    """Compute the connected component to which a segment belong.

    Note:
      only dovetail overlaps are considered as connections

    Parameters:
      segment (str, Line) : a segment name or instance

    Returns:
       list : a list of segment instances
    """
    if visited is None:
      visited = set()
    if isinstance(segment, gfapy.Line):
      segment_name = segment.name
    else:
      segment_name = segment
      segment = self.segment(segment)
    visited.add(segment_name)
    c = set()
    c.add(segment)
    for e in ["L", "R"]:
      self.__traverse_component(gfapy.SegmentEnd(segment, e), c, visited)
    return list(c)

  def connected_components(self):
    """Compute the connected components of the graph.

    Note:
      only dovetail overlaps are considered as connections

    Returns:
       list : a list of lists of segment instances; each sublist is
         a connected component
    """
    components = []
    visited = set()
    for sn in self.segment_names:
      if sn not in visited:
        components.append(self.segment_connected_component(sn, visited))
    return components

  def split_connected_components(self):
    """Split the connected components of the graph.

    Note:
      only dovetail overlaps are considered as connections

    Returns:
      list of Gfa
    """
    retval = []
    for cc in self.connected_components():
      gfa2 = self.clone
      gfa2.rm(gfa2.segment_names - cc)
      retval.append(gfa2)
    return retval

  @property
  def n_dead_ends(self):
    """Number of dead ends in the graph.

    A dead end is a segment end which has no dovetail overlaps.

    Returns:
      int
    """
    n = 0
    for s in self.segments:
      if not s.dovetails_L: n+=1
      if not s.dovetails_R: n+=1
    return n

  @property
  def n_dovetails(self):
    """Number of dovetail overlaps in the graph.

    Returns:
      int
    """
    n = 0
    for s in self.segments:
      n += len(s.dovetails_L)
      n += len(s.dovetails_R)
    return n // 2

  @property
  def n_internals(self):
    """Number of non-dovetail non-containment overlaps in the graph.

    Returns:
      int
    """
    n = 0
    for s in self.segments:
      n += len(s.internals)
    return n // 2

  @property
  def n_containments(self):
    """Number of containment overlaps in the graph.

    Returns:
      int
    """
    n = 0
    for s in self.segments:
      n += len(s.edges_to_contained)
      n += len(s.edges_to_containers)
    return n // 2

  def info(self, short):
    pass

  def __traverse_component(self, segment_end, c, visited):
    s = segment_end.segment
    assert(isinstance(s, gfapy.Line))
    for l in s.dovetails_of_end(segment_end.end_type):
      oe = l.other_end(segment_end)
      sn = oe.name
      s = oe.segment
      if sn in visited:
        continue
      visited.add(sn)
      c.add(s)
      for e in ["L","R"]:
        self.__traverse_component(gfapy.SegmentEnd(s, e), c, visited)
