"""
Update of references caused by a virtual line becoming real.
"""
import gfapy

class UpdateReferences:

  def _update_references(self, oldref, newref, key_in_ref):
    """
    This is called on lines which were referenced by virtual lines,
    when a real line is found which substitutes the virtual line.

    .. note::
      SUBCLASSES which can be referenced by virtual lines
      may implement a specialized *_backreference_keys* method to
      support this mechanism (the default will work in all cases
      of the current specification, but is not optimized for record type)

    Parameters
    ----------
    oldref : gfapy.Line
    newref : gfapy.Line
    key_in_ref : str list
    """
    keys = self._backreference_keys(oldref, key_in_ref)
    assert(keys is not None)
    self.__update_field_references(oldref, newref,
                                  list(set(self.__class__.REFERENCE_FIELDS)
                                       .intersection(keys)))
    if hasattr(self, "_refs"):
      # note: keeping the two types of nonfield references separate helps
      #       in subclasses where only one must be redefined
      self.__update_dependent_line_references(oldref, newref,
                                             set(self.__class__.DEPENDENT_LINES)
                                             .intersection(self._refs.keys())
                                             .intersection(keys))
      self.__update_other_references(oldref, newref,
                                    list(set(self.__class__.OTHER_REFERENCES)
                                    .intersection(self._refs.keys())
                                    .intersection(keys)))

  def _backreference_keys(self, ref, key_in_ref):
    """
    Return a list of fields and/or @ref keys, which indicates
    where a reference "ref" _may_ be stored (in order to be able
    to locate it and update it).

    The default is: all reference fields, dependent line references
    and other references.

    .. note::
      SUBCLASSES may overwrite this method if they
      can be referenced by virtual lines, by providing more
      specific results, depending on the ref and key_in_ref;
      this can make the update faster.

    Returns
    -------
    str list
      Fieldnames and/or _refs keys.
    """
    return (self.__class__.REFERENCE_FIELDS +
            self.__class__.DEPENDENT_LINES +
            self.__class__.OTHER_REFERENCES)

  def __update_reference_in_field(self, field, oldref, newref):
    """
    .. note::
      This methods supports fields which contain references,
      oriented lines or lists of references or oriented lines;
      if SUBCLASSES contain fields which reference to line in a
      different fashion, the method must be updated or overwritten
      by the subclass
    """
    value = self.get(field)
    if isinstance(value, gfapy.Line):
      if value is oldref:
        self._set_existing_field(field, newref, set_reference = True)
    elif isinstance(value, gfapy.OrientedLine):
      if value.line is oldref:
        value.line = newref
    elif isinstance(value, list):
      self.__update_reference_in_list(value, oldref, newref)

  def __update_reference_in_list(self, lst, oldref, newref):
    found = False
    for idx, elem in enumerate(lst):
      if isinstance(elem, gfapy.Line):
        if elem is oldref:
          lst[idx] = newref
          found = True
      elif isinstance(elem, gfapy.OrientedLine):
        if elem.line is oldref:
          if hasattr(oldref, "is_complement") and \
                            oldref.is_complement(newref):
            elem.orient = gfapy.invert(elem.orient)
          elem.line = newref
          found = True
    if newref is None and found:
      lst[:] = [e for e in lst if e is not None]

  def __update_field_references(self, oldref, newref, possible_fieldnames):
    for fn in possible_fieldnames:
      self.__update_reference_in_field(fn, oldref,
          newref if newref else str(oldref))

  def __update_nonfield_references(self, oldref, newref, possible_keys):
    for key in possible_keys:
      if key in self._refs:
        self.__update_reference_in_list(self._refs[key], oldref, newref)

  def __update_dependent_line_references(self ,oldref, newref, possible_keys):
    self.__update_nonfield_references(oldref, newref, possible_keys)

  def __update_other_references(self, oldref, newref, possible_keys):
    """
    .. note:: SUBCLASSES may redefine this method
    """
    self.__update_nonfield_references(oldref, newref, possible_keys)
