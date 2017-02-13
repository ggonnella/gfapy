import gfapy

class References:

  def _prepare_and_check_ref(self, ref):
    if isinstance(ref, str):
      ref = self._line_for_ref_symbol(ref)
    self._check_ref_class(ref)
    self._check_ref_connection(ref)
    self._check_ref_not_self(ref)
    return ref

  def _check_ref_class(self, item):
    if item.__class__ not in [
         gfapy.line.edge.GFA2,
         gfapy.line.segment.GFA2,
         gfapy.line.gap.Gap,
         gfapy.line.group.Ordered,
         self.__class__]:
      raise gfapy.ArgumentError(
        "Line: {}\n".format(self)+
        "Cannot add items of class {}\n".format(item.__class__.__name__)+
        "Only GFA2 edges, segments, gaps, groups[*] "+
        "can be added\n(* = unordered groups to unordered groups only).")

  def _check_ref_connection(self, item):
    if item.line.gfa != self._gfa:
      raise gfapy.ArgumentError(
        "Line: {}\n".format(self)+
        "Item: {}".format(repr(item))+
        "The item added to the group must be connected\n"+
        "to the same GFA object as the group")

  def _check_ref_not_self(self, item):
    if (item.line == self):
      raise gfapy.RuntimeError(
        "Line: {}\n".format(self)+
        "Item is the line itself\n"+
        "A group is not allowed to refer to itself")

  def _line_for_ref_symbol(self, ref):
    line = self._gfa.line(ref)
    if line is None:
      if self._gfa._segments_first_order:
        raise gfapy.NotFoundError("Group: {}\n".format(self)+
                        "requires a non-existing ref with ID {}".format(ref))
      line = gfapy.line.unknown.Unknown({"name" : ref}, virtual = True,
                                        version = "gfa2")
      self._gfa.add_line(line)
    line._add_reference(self, "paths" if (self.record_type == "O") else "sets")
    return line
