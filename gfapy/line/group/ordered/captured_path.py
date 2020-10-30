import gfapy

class CapturedPath:

  @property
  def captured_segments(self):
    return [ x for x in self.captured_path if isinstance(x.line, gfapy.line.segment.GFA2) ]

  @property
  def captured_edges(self):
    return [ x for x in self.captured_path if isinstance(x.line, gfapy.line.edge.GFA2) ]

  @property
  def captured_path(self):
    if not self.is_connected():
      raise gfapy.RuntimeError(
        "Captured path cannot be computed\n"+
        "Line is not connected to a GFA instance\n"+
        "Line: {}".format(self))
    return self._compute_captured_path()[0]

  def _compute_captured_path(self):
    path = []
    prev_edge = False
    for item in self.items:
      path, prev_edge = self._push_item_on_se_path(path, prev_edge, item)
    return path, prev_edge

  def _push_item_on_se_path(self, path, prev_edge, item):
    if isinstance(item.line, str):
      raise gfapy.RuntimeError(
        "Captured path cannot be computed; a reference has not been resolved\n"+
        "Line: {}\n".format(self)+
        "Unresolved reference: {} (String found)".format(item.line))
    elif isinstance(item.line, gfapy.line.segment.GFA2):
      if not item.line.is_connected():
        raise gfapy.RuntimeError(
          "Captured path cannot be computed; item is not connected\n"+
          "Line: {}\n".format(self)+
          "Item: {}".format(item.line))
      self._push_segment_on_se_path(path, prev_edge, item)
      prev_edge = False
    elif isinstance(item.line, gfapy.line.edge.GFA2):
      if not item.line.is_connected():
        raise gfapy.RuntimeError(
          "Captured path cannot be computed; item is not connected\n"+
          "Line: {}\n".format(self)+
          "Item: {}".format(item.line))
      if not path:
        self._push_first_edge_on_se_path(path, self.items)
      else:
        self._push_nonfirst_edge_on_se_path(path, item)
      prev_edge = True
    elif isinstance(item.line, gfapy.line.group.Ordered):
      if not item.line.is_connected():
        raise gfapy.RuntimeError(
          "Captured path cannot be computed; item is not connected\n"+
          "Line: {}\n".format(self)+
          "Item: {}".format(item.line))
      subpath, prev_edge_subpath = item.line._compute_captured_path()
      if not subpath:
        raise gfapy.AssertionError()
      if item.orient == "+":
        for subpath_item in subpath:
          path, prev_edge = self._push_item_on_se_path(path, prev_edge,
              subpath_item)
      else:
        for subpath_item in reversed(subpath):
          path, prev_edge = self._push_item_on_se_path(path, prev_edge,
              subpath_item.inverted())
      prev_edge = prev_edge_subpath
    elif isinstance(item.line, gfapy.line.unknown.Unknown):
      raise gfapy.RuntimeError(
        "Captured path cannot be computed; a reference has not been resolved\n"+
        "Line: {}\n".format(self)+
        "Unresolved reference: {} (Virtual unknown line)".format(item.name))
    else:
      raise gfapy.TypeError(
        "Line: {}\t".format(self)+
        "Cannot compute captured path:\t"+
        "Error: items of type {} are not supported\t".format(item.line.__class__.__name__)+
        "Unsupported item: {}".format(item))
    return path, prev_edge

  def _push_first_edge_on_se_path(self, path, items):
    oriented_edge = items[0]
    oss = [oriented_edge.line.sid1, oriented_edge.line.sid2]
    if oriented_edge.orient == "-":
      for i in range(len(oss)):
        oss[i] = oss[i].inverted()
    if len(items) > 1:
      nextitem = items[1]
      if isinstance(nextitem.line, gfapy.line.segment.GFA2):
        if nextitem == oss[0]:
          oss.reverse()
        # if oss does not include nextitem an error will be raised
        # in the next iteration, so does not need to be handled here
      elif isinstance(nextitem.line, gfapy.line.edge.GFA2):
        oss_of_next = [nextitem.line.sid1, nextitem.line.sid2]
        if oriented_edge.orient == "-":
          for i in range(len(oss_of_next)):
            oss_of_next[i] = oss_of_next[i].inverted()
        if oss[0] in oss_of_next:
          oss.reverse()
        # if oss_of_next have no element in common with oss an error will be
        # raised in the next iteration, so does not need to be handled here
      elif isinstance(nextitem.line, gfapy.line.group.Ordered):
        subpath = nextitem.line.captured_path
        if not subpath: return# does not need to be further handled here
        if nextitem.orient == "+":
          firstsubpathsegment = subpath[0]
        else:
          firstsubpathsegment = subpath[-1].inverted()
        if firstsubpathsegment == oss[0]:
          oss.reverse()
        # if oss does not include in firstsubpathsegment
        # error will be raised in next iteration, ie not handled here
      else:
        pass
        # don't need to handle here other cases, as they will be handled
        # in the next iteration of push_item_on_se_path
    path.append(oss[0])
    path.append(oriented_edge)
    path.append(oss[1])

  def _push_nonfirst_edge_on_se_path(self, path, oriented_edge):
    prev_os = path[-1]
    path.append(oriented_edge)
    possible_prev = [oriented_edge.line.sid1, oriented_edge.line.sid2]
    if oriented_edge.orient == "-":
      for i, v in enumerate(possible_prev):
        possible_prev[i] = possible_prev[i].inverted()
    if prev_os == possible_prev[0]:
      path.append(possible_prev[1])
    elif prev_os == possible_prev[1]:
      path.append(possible_prev[0])
    else:
      raise gfapy.NotFoundError(
        "Path is not valid, elements are not contiguous\n"+
        "Line: {}\n".format(self)+
        "Previous elements:\n"+
        "".join(["  {} ({})\n".format(e, e.line) for e in path])+
        "Current element:\n"+
        "  {} ({})".format(oriented_edge, oriented_edge.line))

  def _push_segment_on_se_path(self, path, prev_edge, oriented_segment):
    if path:
      if isinstance(path[-1].line, gfapy.line.segment.GFA2):
        if prev_edge:
          self._check_s_is_as_expected(path, oriented_segment)
          return # do not add segment, as it is already there
        else:
          path.append(self._find_edge_from_path_to_segment(path, oriented_segment))
      elif isinstance(path[-1].line, gfapy.line.edge.GFA2):
        self._check_s_to_e_contiguity(path, oriented_segment)
      else:
        raise gfapy.AssertionError()
    path.append(oriented_segment)

  def _check_s_is_as_expected(self, path, oriented_segment):
    if path[-1] != oriented_segment:
      raise gfapy.InconsistencyError(
        "Path is not valid\n"+
        "Line: {}\n".format(self)+
        "Previous elements:\n"+
        "".join(["  {} ({})\n".format(e, e.line) for e in path[0:-2]])+
        "Expected element:\n"+
        "  {} ({})\n".format(path[-1], path[-1].line)+
        "Current element:\n"+
        "  {} ({})\n".format(oriented_segment, oriented_segment.line))

  def _check_s_to_e_contiguity(self, path, oriented_segment):
    # check that segment is an extremity of path[-1]
    # and that the other extremity is path[-2]
    if not (path[-1].sid1 == self.segment and path[-1].sid2 == path[-2]) and \
       not (path[-1].sid1 == path[-2] and path[-1].sid2 == self.segment):
      raise gfapy.InconsistencyError(
        "Path is not valid\n"+
        "Line: {}\n".format(self)+
        "Previous elements:\n"+
        "".join(["  {} ({})\n".format(e, e.line) for e in path])+
        "Current element:\n"+
        "  {} ({})\n".format(oriented_segment, oriented_segment.line))

  def _find_edge_from_path_to_segment(self, path, oriented_segment):
    edges = []
    for edge in oriented_segment.line.edges:
      if (edge.sid1 == oriented_segment and edge.sid2 == path[-1]) or \
         (edge.sid1 == path[-1] and edge.sid2 == oriented_segment):
        edges.append(gfapy.OrientedLine(edge, "+"))
      elif (edge.sid1 == oriented_segment.inverted() and
            edge.sid2 == path[-1].inverted()) or\
           (edge.sid1 == path[-1].inverted() and
            edge.sid2 == oriented_segment.inverted()):
        edges.append(gfapy.OrientedLine(edge, "-"))
    if len(edges) == 0:
      raise gfapy.NotFoundError(
        "Path is not valid, segments are not contiguous\n"+
        "Line: {}\n".format(self)+
        "Previous elements:\n"+
        "".join(["  {} ({})\n".format(e, e.line) for e in path])+
        "Current element:\n"+
        "  {} ({})\n".format(oriented_segment, oriented_segment.line))
    elif len(edges) > 1:
      raise gfapy.NotUniqueError(
        "Path is not unique\n"+
        "Line: {}\n".format(self)+
        "Previous elements:\n"+
        "".join(["  {} ({})\n".format(e, e.line) for e in path])+
        "Current element:\n"+
        "  {} ({})\n".format(oriented_segment, oriented_segment.line)+
        "Possible edges\n"+
        "".join(["  {} ({})\n".format(e, e.line) for e in edges]))
    return edges[0]

  def _check_captured_path_elem_connected(self, item):
    if not item.is_connected():
      raise gfapy.RuntimeError(
        "Cannot compute induced set\n"+
        "Non-connected element found\n"+
        "Item: {}\nLine: {}".format(item, self))
