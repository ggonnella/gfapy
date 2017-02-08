import gfapy

class Writer:

  def __str__(self):
    """
    Returns
    -------
    str
      A string representation of self.
    """
    return gfapy.Line.SEPARATOR.join(self.to_list())

  def to_list(self):
    """
    Returns
    -------
    str list
      A list of string representations of the fields.
    """
    a = [ self.record_type ] + \
        [ self.field_to_s(fn, tag = False) for fn in self.positional_fieldnames ] + \
        [ self.field_to_s(fn, tag = True) for fn in self.tagnames ]
    if self.is_virtual():
      a.append("co:Z:GFAPY_virtual_line")
    return a

  def field_to_s(self, fieldname, tag = False):
    """
    Compute the string representation of a field.

    Parameters
    ----------
    fieldname : str
      The tag name of the field.
    tag : bool
      *(defaults to: ***false***)*
      Return the tagname:datatype:value representation.

    Raises
    ------
    gfapy.NotFoundError
      If field is not defined.

    Returns
    -------
    str
      The string representation
    """
    fieldname = self.__class__.FIELD_ALIAS.get(fieldname, fieldname)
    field = self.data.get(fieldname, None)
    if field is None:
      raise gfapy.NotFoundError("No value defined for tag {}".format(fieldname))
    t = self._field_or_default_datatype(fieldname, field)
    if not isinstance(field, str):
      field = gfapy.field.to_gfa_field(field, datatype = t, fieldname = fieldname)
    if self.vlevel >= 2:
      field.validate_gfa_field(t, fieldname)
    return gfapy.field.to_gfa_tag(field, fieldname, datatype = t) if tag else field

  def __repr__(self):
    local_refs = None
    local_gfa = None
    if hasattr(self, "refs") and getattr(self, "refs") is not None:
      local_refs = self.refs
      self.refs = {}
      for k, v in local_refs.items():
        if not self.refs.get(k, None):
          self.refs[k] = []
        for l in v:
          self.refs[k].append(str(l).replace("\t", " "))
    if self.gfa is not None:
      local_gfa = self.gfa
      self.gfa = "<GFAPY:{}>".format(local_gfa.object_id)
    retval = super().__repr__()
    if local_refs: self.refs = local_refs
    if local_gfa: self.gfa = local_gfa
    return retval

  @property
  def _tags(self):
    """
    Returns the tags as an array of [fieldname, datatype, value]
    triples.

    Returns
    -------
    (str, str, object) list
    """
    retval = []
    for of in tagnames:
      retval.append([of, self.get_datatype(of), self.get(of)])
    return retval
