import gfapy

class Destructors:
  def rm(self, gfa_line):
    self.try_get_line(gfa_line).disconnect()
    return self

  def delete_other_links(self, segment_end, other_end, conserve_components = False):
    segment_end = segment_end.to_segment_end()
    other_end = other_end.to_segment_end()
    s = self.try_get_segment(segment_end.segment)
    for d in s.dovetails_of_end(segment_end.end_type):
      if not conserve_components or not self.is_cut_link(l):
        l.disconnect()

  def _unregister_line(self, gfa_line):
    self._api_private_check_gfa_line(gfa_line, "unregister_line")
    if gfa_line.record_type == "H":
      raise gfapy.AssertionError("Bug found, please report\n"+
        "gfa_line: {}".format(gfa_line))
    collection = self._records[gfa_line.record_type]
    key = gfa_line
    delete_if_empty = None
    if isinstance(collection,dict):
      storage_key = gfa_line.__class__.STORAGE_KEY
      if storage_key == "name":
        if not gfapy.is_placeholder(gfa_line.name):
          key = gfa_line.name
        else:
          collection = collection[None]
      elif storage_key == "external":
        collection = collection[gfa_line.external.name]
        delete_if_empty = gfa_line.external.name
    if isinstance(collection,list):
      collection[:] = [line for line in collection if line is not key]
    else:
      collection.pop(key)
    if delete_if_empty and not collection:
      self._records[gfa_line.record_type].pop(delete_if_empty)
