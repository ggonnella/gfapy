import gfapy

class Destructors:

  def rm(self, gfa_line):
    """Remove a line from the Gfa instance.

    Parameters:
      gfa_line (Line, str): if a Line instance, then disconnect is called
        on it; otherwise, it is assumed to be a line identifier, the
        corresponding line is searched and then disconnected.

    Raises:
      gfapy.error.NotFoundError : is the line is specified using an identifier,
        an no line exists in the Gfa instance, with that identifier
    """
    self.try_get_line(gfa_line).disconnect()

  def _delete_other_links(self, segment_end, other_end,
                         conserve_components = False):
    segment_end = gfapy.SegmentEnd(segment_end)
    other_end = gfapy.SegmentEnd(other_end)
    s = self.try_get_segment(segment_end.segment)
    for d in s.dovetails_of_end(segment_end.end_type):
      if not conserve_components or not self.is_cut_link(d):
        d.disconnect()

  def _unregister_line(self, gfa_line):
    self._api_private_check_gfa_line(gfa_line, "unregister_line")
    rt = gfa_line.record_type
    if rt == "H":
      raise gfapy.AssertionError("Bug found, please report\n"+
        "gfa_line: {}".format(gfa_line))
    collection = self._records[rt]
    storage_key = gfa_line.__class__.STORAGE_KEY
    if storage_key == "name":
      name = gfa_line.name
      if gfapy.is_placeholder(name):
        name = id(gfa_line)
      collection.pop(name)
    elif storage_key == "external":
      subkey = gfa_line.external.name
      collection = collection[subkey]
      collection.pop(id(gfa_line))
      if not collection:
        self._records[rt].pop(subkey)
    else:
      collection.pop(id(gfa_line))
