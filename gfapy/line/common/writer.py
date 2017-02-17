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
    if self.virtual:
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
      *(defaults to: ***False***)*
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
    v = self._data.get(fieldname, None)
    if v is None:
      raise gfapy.NotFoundError("Field {} not found".format(fieldname))
    t = self._field_or_default_datatype(fieldname, v)
    if not isinstance(v, str):
      v = gfapy.Field.to_gfa_field(v, datatype = t, fieldname = fieldname)
    if self.vlevel >= 2:
      gfapy.Field.validate_gfa_field(v, t, fieldname)
    return gfapy.Field.to_gfa_tag(v, fieldname, datatype = t) if tag else v

  def __repr__(self):
    return "gfapy.Line('{0}',version={1},vlevel={2})".format(
        str(self),self.version,self.vlevel)

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
