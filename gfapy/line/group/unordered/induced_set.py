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
    return iss + ise

  @property
  def induced_edges_set(self):
    if not self.is_connected():
      raise gfapy.RuntimeError(
        "Induced set cannot be computed\n"+
        "Line is not connected to a GFA instance\n"+
        "Line: {}".format(self))
    return self._compute_induced_edges_set(self.induced_segments_set)

  @property
  def induced_segments_set(self):
    if not self.is_connected():
      raise gfapy.RuntimeError(
        "Induced set cannot be computed\n"+
        "Line is not connected to a GFA instance\n"+
        "Line: {}".format(self))
    segments_set = list()
    for item in self.items:
      if isinstance(item, str):
        raise gfapy.RuntimeError(
          "Induced set cannot be computed; a reference has not been resolved\n"+
          "Line: {}\n".format(self)+
          "Unresolved reference: {} (String found)".format(item.line))
      elif isinstance(item, gfapy.line.segment.GFA2):
        self._check_induced_set_elem_connected(item)
        segments_set.append(item)
      elif isinstance(item, gfapy.line.edge.GFA2):
        self._check_induced_set_elem_connected(item)
        for sl in [item.sid1.line, item.sid2.line]:
          self._check_induced_set_elem_connected(sl)
          segments_set.append(sl)
      elif isinstance(item, gfapy.line.group.Ordered):
        self._check_induced_set_elem_connected(item)
        subset = item.captured_segments
        assert(subset)
        for elem in subset:
          segments_set.append(elem.line)
      elif isinstance(item, gfapy.line.group.Unordered):
        self._check_induced_set_elem_connected(item)
        subset = item.induced_segments_set
        assert(subset)
        for elem in subset:
          segments_set.append(elem)
      elif isinstance(item, gfapy.line.Unknown):
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
    unique_ids = set()
    return [e for e in segments_set \
        if id(e) not in unique_ids and not unique_ids.add(id(e))]

  def _check_induced_set_elem_connected(self, item):
    if not item.is_connected():
      raise gfapy.RuntimeError(
        "Cannot compute induced set\n"+
        "Non-connected element found\n"+
        "Item: {}\nLine: {}".format(item, self))

  def _compute_induced_edges_set(self, segments_set):
    edges_set = list()
    for item in segments_set:
      for edge in item.edges:
        if edge.other(item) in segments_set:
          edges_set.append(edge)
    unique_ids = set()
    return [e for e in edges_set \
        if id(e) not in unique_ids and not unique_ids.add(id(e))]
