import gfapy

class References:

  def add_item(self, item):
    """
    Add an item to the group.

    Parameters
    ----------
    item : gfapy.Line, str
      GFA2 edge, segment, gap or group line to add.
    """
    if not self.is_connected():
      self._add_item_to_unconnected_group(item)
    else:
      self._add_item_to_connected_group(item)

  def rm_item(self, item):
    """
    Remove an item from the group.

    Parameters
    ----------
    item : str, gfapy.Line
      GFA2 edge, segment, gap or group line to remove.
    """
    if not self.is_connected():
      self._rm_item_from_unconnected_group(item)
    else:
      self._rm_item_from_connected_group(item)

  def _rm_item_from_unconnected_group(self, item):
    if isinstance(item, gfapy.Line):
      item = item.name
    self._check_item_included(item)
    self.items.delete(item)
    return None

  def _rm_item_from_connected_group(self, item):
    if isinstance(item, str):
      item = self._gfa.line(item)
    self._check_item_included(item)
    item._delete_reference(self, "sets")
    self._delete_reference(item, "items")
    return None

  def _check_item_included(self, item):
    if item not in self.items:
      raise gfapy.NotFoundError(
        "Line: {}\n".format(self)+
        "Item: {}".format(repr(item))+
        "Items of the line do not include the item")

  def _add_item_to_unconnected_group(self, item, append = True):
    if isinstance(item, gfapy.Line):
      item = item.name
    if append:
      self.items.append(item)
    else:
      self.items.insert(0, item)
    return None

  def _add_item_to_connected_group(self, item, append = True):
    self._add_reference(self.prepare_and_check_ref(item),
                       "items", append = append)
    return None

  def _initialize_references(self):
    for i in range(len(self.items)):
      self.items[i] = self._line_for_ref_symbol(self.items[i])
