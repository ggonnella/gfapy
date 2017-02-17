"""
Methods in this module are important for lines
which can be virtual
"""
import gfapy

class VirtualToReal:

  @property
  def virtual(self):
    """
    Is the line virtual?

    Is this gfapy.Line a virtual line representation
    (i.e. a placeholder for an expected but not yet encountered line)?

    Returns
    -------
    bool
    """
    return self._virtual

  def _substitute_virtual_line(self, previous):
    self._gfa = previous.gfa
    self._import_references(previous)
    self._gfa._unregister_line(previous)
    self._gfa._register_line(self)
    return None

  def _import_references(self, previous):
    """
    This is called when a virtual line (previous) is
    substituted by a real line
    """
    if not isinstance(previous, gfapy.line.Unknown):
      self._import_field_references(previous)
      self._update_field_backreferences(previous)
    else:
      self._initialize_references()
    self._import_nonfield_references(previous)
    self._update_nonfield_backreferences(previous)

  def _import_field_references(self, previous):
    for k in (self.__class__.REFERENCE_FIELDS +
              self.__class__.BACKREFERENCE_RELATED_FIELDS):
      ref = previous.get(k)
      self._set_existing_field(k, ref, set_reference = True)

  def _update_backreference_in(self, ref, previous, k):
    if isinstance(ref, gfapy.Line):
      ref._update_references(previous, self, k)
    elif isinstance(ref, gfapy.OrientedLine):
      ref.line._update_references(previous, self, k)
    elif isinstance(ref, list):
      for item in ref:
        self._update_backreference_in(item, previous, k)

  def _update_field_backreferences(self, previous):
    """
    .. note::
      Currently this method supports fields which are: references,
      oriented lines and lists of references of oriented lines.
      If SUBCLASSES have reference fields which contain references
      in a different fashion, the method must be updated or overwritten
      in the subclass.
    """
    for k in self.__class__.REFERENCE_FIELDS:
      ref = self.get(k)
      self._update_backreference_in(ref, previous, k)

  def _import_nonfield_references(self, previous):
    self._refs = previous._refs

  def _update_nonfield_backreferences(self, previous):
    for k, v in self._refs.items():
      for ref in v:
        self._update_backreference_in(ref, previous, k)
