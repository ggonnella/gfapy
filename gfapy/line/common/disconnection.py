import gfapy

class Disconnection:

  def disconnect(self):
    """
    Remove the line from the GFA instance it belongs to, if any.

    The Line instance itself will still exist, but all references from it to
    other lines are deleted, as well as references to it from other lines.
    Mandatory references are turned into their non-reference representations
    (e.g. segments references in the sid fields of E lines
    or in the from/to lines of L/C lines are changed into symbols).
    """
    if not self.is_connected():
      raise gfapy.RuntimeError(
        "Line {} is not connected to a GFA instance".format(self))
    self._remove_field_backreferences()
    self._remove_field_references()
    self._disconnect_dependent_lines()
    self._remove_nonfield_backreferences()
    self._remove_nonfield_references()
    self._gfa._unregister_line(self)
    self._gfa = None

  def _delete_reference(self, line, key):
    if key not in self._refs: return
    idx = None
    for i, x in enumerate(self._refs[key]):
      if x is line:
        idx = i
    if idx is None:
      return
    elif idx == 0:
      self._refs[key].pop(0)
    elif idx == len(self._refs[key])-1:
      self._refs[key].pop()
    else:
      self._refs[key] = (self._refs[key][0:idx] + self._refs[key][idx+1:])

  def _delete_first_reference(self, key):
    if not self._refs or not self._refs[key]:
      return
    self._refs[key].pop(0)

  def _delete_last_reference(self, key):
    if not self._refs or not self._refs[key]:
      return
    self._refs[key].pop()

  def _remove_field_references(self):
    """
    .. note::
      currently this method supports fields which are: references,
      oriented lines and lists of references of oriented lines;
      if SUBCLASSES have reference fields which contain references
      in a different fashion, the method must be updated or overwritten
      in the subclass
    """
    for k in self.__class__.REFERENCE_FIELDS:
      ref = self.get(k)
      if isinstance(ref, gfapy.Line):
        self._set_existing_field(k, ref.name, set_reference = True)
      elif isinstance(ref, gfapy.OrientedLine):
        ref.line = ref.name
      elif isinstance(ref, list):
        for i, elem in enumerate(ref):
          if isinstance(elem, gfapy.Line):
            ref[i] = elem.name
          elif isinstance(elem, gfapy.OrientedLine):
            ref[i].line = elem.name

  def _remove_backreference(self, ref, k):
    if isinstance(ref, gfapy.Line):
      ref._update_references(self, None, k)
    elif isinstance(ref, gfapy.OrientedLine):
      if isinstance(ref.line, gfapy.Line):
        ref.line._update_references(self, None, k)
    elif isinstance(ref, list):
      for i in range(len(ref)):
       self._remove_backreference(ref[i], k)

  def _disconnect_dependent_line(self, ref):
    if isinstance(ref, gfapy.Line):
      ref.disconnect()
    elif isinstance(ref, gfapy.OrientedLine):
      if isinstance(ref.line, gfapy.Line):
        ref.line.disconnect()
    elif isinstance(ref, list):
      for i in range(len(ref)):
        self._disconnect_dependent_line(ref[i])

  def _remove_field_backreferences(self):
    """
    .. note::
      currently this method supports fields which are: references,
      oriented lines and lists of references of oriented lines;
      if SUBCLASSES have reference fields which contain references
      in a different fashion, the method must be updated or overwritten
      in the subclass
    """
    for k in self.__class__.REFERENCE_FIELDS:
      self._remove_backreference(self.get(k), k)

  def _disconnect_dependent_lines(self):
    for k in self.__class__.DEPENDENT_LINES:
      for ref in self._refs.get(k, []):
        self._disconnect_dependent_line(ref)

  def _remove_nonfield_backreferences(self):
    for k in self.__class__.OTHER_REFERENCES:
      for ref in self._refs.get(k, []):
        self._remove_backreference(ref, k)

  def _remove_nonfield_references(self):
    self._refs = {}
