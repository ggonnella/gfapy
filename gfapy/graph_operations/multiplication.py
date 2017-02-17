import gfapy
import re

class Multiplication:

  def multiply(self, segment, factor, copy_names = None,
               conserve_components = True, distribute = None,
               track_origin = False, origin_tag="or", extended = False):
    if extended:
      if distribute == None:
        distribute = "auto"
      track_origin = True
    if factor < 0:
      raise gfapy.ArgumentError("Mulitiplication factor must be >= 0"+
          " ({} found)".format(factor))
    elif factor == 0:
      if conserve_components and factor == 1 and is_cut_segment(segment):
        return self
      else:
        self.rm(segment)
        return self
    elif factor == 1:
      return self
    else:
      s, sn = self._segment_and_segment_name(segment)
      if track_origin and not s.get(origin_tag):
        s.set(origin_tag, sn)
      self.__divide_segment_and_connection_counts(s, factor)
      if copy_names is None:
        copy_names = self._compute_copy_names(sn, factor)
      for cn in copy_names:
        self.__clone_segment_and_connections(s, cn)
      if distribute:
        self._distribute_links(distribute, sn, copy_names, factor)
      return self

  def _compute_copy_names(self, segment_name, factor):
    assert factor >= 2
    retval = []
    first = 2
    m = re.search(r'(.*)\*(\d+)',segment_name)
    if m:
      segment_name = m.groups()[0]
      i = int(m.groups()[1])
    offset = 0
    for i in range(first,factor+first-1):
      name = "{}*{}".format(segment_name, i+offset)
      while name in self.names:
        offset+=1
        name = "{}*{}".format(segment_name, i+offset)
      retval.append(name)
    return retval

  def __divide_counts(self, gfa_line, factor):
    for count_tag in ["KC", "RC", "FC"]:
      if count_tag in gfa_line.tagnames:
        gfa_line.set(count_tag, gfa_line.get(count_tag) // factor)

  def __divide_segment_and_connection_counts(self, segment, factor):
    self.__divide_counts(segment, factor)
    processed_circulars = set()
    for l in segment.dovetails + segment.containments:
      if l.is_circular():
        if l not in processed_circular:
          self.__divide_counts(l, factor)
          processed_circular.append(l)
      else:
        self.__divide_counts(l, factor)

  def __clone_segment_and_connections(self, segment, clone_name):
    cpy = segment.clone()
    cpy.name = clone_name
    cpy.connect(self)
    for l in segment.dovetails + segment.containments:
      lc = l.clone()
      if lc.from_segment == segment.name:
        lc.from_segment = clone_name
      if lc.to_segment == segment.name:
        lc.to_segment = clone_name
      lc.connect(self)

