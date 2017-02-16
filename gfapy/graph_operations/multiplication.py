import gfapy
import re

class Multiplication:

  def multiply(self, segment, factor, copy_names = None,
               conserve_components = True):
    if factor < 0:
      raise gfapy.ArgumentError("Mulitiplication factor must be >= 0"+
          " ({} found)".format(factor))
    elif factor == 0:
      if conserve_components and factor == 1 and is_cut_segment(segment):
        return self
      else:
        return self.rm(segment)
    elif factor == 1:
      return self
    else:
      if isinstance(segment, str):
        segment_name = segment
        segment = self.try_get_segment(segment)
      self.__divide_segment_and_connection_counts(segment, factor)
      if copy_names is None:
        copy_names = self.__compute_copy_names(segment_name, factor)
      for cn in copy_names:
        self.__clone_segment_and_connections(segment, cn)
      return self

  def __compute_copy_names(self, segment_name, factor):
    assert factor >= 2
    retval = []
    first = 2
    m = re.search(r'(.*)\*(\d+)',segment_name)
    if m:
      segment_name = m.groups()[0]
      i = int(m.groups()[1])
    offset = 0
    for i in range(first,factor+first):
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
      if lc.get("from") == segment.name:
        lc.set("from", clone_name)
      if lc.to == segment.name:
        lc.to = clone_name
      lc.connect(self)

