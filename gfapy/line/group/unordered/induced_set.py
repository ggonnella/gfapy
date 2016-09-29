import gfapy

class InducedSet:

  @property
  def induced_set(self):
    if not self.is_connected:
      raise gfapy.RuntimeError(
        "Induced set cannot be computed\n"+
        "Line is not connected to a GFA instance\n"+
        "Line: {}".format(self))
    iss = self.induced_segments_set
    ise = self._compute_induced_edges_set(iss)
    return frozenset(iss + ise)

  @property
  def induced_edges_set(self):
    if not self.is_connected():
      raise gfapy.RuntimeError(
        "Induced set cannot be computed\n"+
        "Line is not connected to a GFA instance\n"+
        "Line: {}".format(self))
    return frozenset(self._compute_induced_edges_set(self.induced_segments_set))

  @property
  def induced_segments_set(self):
    if not self.is_connected():
      raise gfapy.RuntimeError(
        "Induced set cannot be computed\n"+
        "Line is not connected to a GFA instance\n"+
        "Line: {}".format(self))
    segments_set = set()
    for item in self.items:
      if isinstance(item, str):
        raise gfapy.RuntimeError(
          "Induced set cannot be computed; a reference has not been resolved\n"+
          "Line: {}\n".format(self)+
          "Unresolved reference: {} (String found)".format(item.line))
      elif isinstance(item, gfapy.line.segment.GFA2):
        self._check_induced_set_elem_connected(item)
        segments_set.add(item)
      elif isinstance(item, gfapy.line.edge.GFA2):
        self._check_induced_set_elem_connected(item)
        for sl in [item.sid1.line, item.sid2.line]:
          self._check_induced_set_elem_connected(sl)
          segments_set.add(sl)
      elif isinstance(item, gfapy.line.group.Ordered):
        self._check_induced_set_elem_connected(item)
        subset = item.captured_segments
        if not subset:
          raise gfapy.AssertionError()
        for elem in subset:
          segments_set.add(elem)
      elif isinstance(item, gfapy.line.group.Unordered):
        self._check_induced_set_elem_connected(item)
        subset = item.induced_segments_set
        if not subset:
          raise gfapy.AssertionError()
        for elem in subset:
          segments_set.add(elem)
      elif isinstance(item, gfapy.line.Unkown):
        raise gfapy.RuntimeError(
          "Induced set cannot be computed; a reference has not been resolved\n"+
          "Line: {}\n".format(self)+
          "Unresolved reference: {} (Virtual unknown line)".format(item.name))
      else:
        raise gfapy.TypeError(
          "Line: {}\t".format(self)+
          "Cannot compute induced set:\t"+
          "Error: items of type {} are not supported\t".format(item.__class__.__name__)+
          "Unsupported item: {}".format(item))
      return list(segments_set)

  def _check_induced_set_elem_connected(self, item):
    if not item.is_connected():
      raise gfapy.RuntimeError(
        "Cannot compute induced set\n"+
        "Non-connected element found\n"+
        "Item: {}\nLine: {}".format(item, self))

  def _compute_induced_edges_set(self, segments_set):
    edges_set = set()
    for item in segments_set:
      for edge in item.edges:
        if edge.other(item) in segments_set:
          edges_set.add(edge)
    return list(edges_set)
