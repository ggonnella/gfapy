import gfapy

class References:

  def append_item(self, item):
    """
    Add an item to the group as last item.

    Parameters
    ----------
    item : gfapy.Line or str
    	GFA2 edge, segment, gap or group line to add.
    """
    if not self.is_connected():
      self._add_item_to_unconnected_group(item, True)
    else:
      self._add_item_to_connected_group(item, True)
      self.compute_induced_set() # check contiguity

  def prepend_item(self, item):
    """
    Add an item to the group as first item.

    Parameters
    ----------
    item : gfapy.Line or str
    	GFA2 edge, segment, gap or group line to add.
    """
    if not self.is_connected():
      self._add_item_to_unconnected_group(item, False)
    else:
      self._add_item_to_connected_group(item, False)
      self.compute_induced_set() # check contiguity

  def rm_first_item(self):
    """
    Remove the first item from the group.

    Parameters
    ----------
    item : str or gfapy.Line
    	GFA2 edge, segment, gap or group line to remove.
    """
    if not self.is_connected():
      self.items = self.items[1:]
    else:
      self.items[0].update_reference(self, "paths")
      self._delete_reference(self.items[0], "items")
      self.compute_induced_set() # check contiguity

  def rm_last_item(self):
    """
    Remove the last item from the group.

    Parameters
    ----------
    item : str or gfapy.Line
    	GFA2 edge, segment, gap or group line to remove.
    """
    if not self.is_connected():
      self.items = self.items[0:-1]
    else:
      self.items[-1].update_reference(self, "paths")
      self._delete_reference(self.items[-1], "items")
      self.compute_induced_set() # check contiguity

  def _add_item_to_unconnected_group(self, item, append = True):
    if isinstance(item.line, gfapy.Line):
      item.line = item.name
    if append:
      self.items.append(item)
    else:
      self.items.insert(0, item)

  def _add_item_to_connected_group(self, item, append = True):
    item.line = self.prepare_and_check_ref(item.line)
    self._add_reference(item, "items", append = append)

  def _initialize_references(self):
    for i in range(len(self.items)):
      self.items[i].line = self._line_for_ref_symbol(self.items[i].line)
