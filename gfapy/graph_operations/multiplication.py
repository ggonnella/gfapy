import gfapy

class Multiplication:

  def multiply(self, segment, factor, copy_names="lowcase",
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
      for cn in self.__compute_copy_names(copy_names, segment_name, factor):
        self.__clone_segment_and_connections(s, cn)
      return self

  def __compute_copy_names(self, copy_names, segment_name, factor):
    assert factor >= 2
    accepted = ["lowcase", "upcase", "number", "copy"]
    if isinstance(copy_names, list):
      return copy_names
    elif copy_names not in accepted:
      raise gfapy.ArgumentError("copy_names shall be an array of "+
          "names or one of: "+",".join(accepted))
    retval = []
  # TODO

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
    cpy = segment.clone
    cpy.name = clone_name
    cpy.connect(self)
    for l in segment.dovetails + segment.containments:
      lc = l.clone
      if lc.get("from") == segment.name:
        lc.set("from", clone_name)
      if lc.to == segment.name:
        lc.to = clone_name
      lc.connect(self)

