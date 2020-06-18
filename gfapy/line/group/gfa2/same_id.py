import gfapy

class SameID:

  def _process_not_unique(self, previous):
    self._gfa = previous.gfa
    self._initialize_references()
    cur_items = self.get("items")
    self._substitute_virtual_line(previous)
    self._set_existing_field("items", self.get("items") + cur_items, 
                            set_reference = True)
    self._import_tags_of_previous_group_definition(previous)
    return None

  def _import_tags_of_previous_group_definition(self, previous):
    for tag in previous.tagnames:
      prv = previous.get(tag)
      cur = self.get(tag)
      if cur:
        if cur != prv:
          raise gfapy.NotUniqueError(
            "Same tag defined differently in "+
            "multiple group lines with same ID\n"+
            "Previous tag definition: {}\n".format(prv)+
            "New tag definition: {}\n".format(cur)+
            "Group ID: {}".format(self.name))
      else:
        self.set(tag, prv)
