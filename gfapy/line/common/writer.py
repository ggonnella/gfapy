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
    a = [self.record_type]
    errors = []
    for fn in self.positional_fieldnames:
      try:
        fstr = self.field_to_s(fn, tag = False)
      except:
        fstr = str(self.get(fn))
        errors.append(fn)
      a.append(fstr)
    for fn in self.tagnames:
      try:
        fstr = self.field_to_s(fn, tag = True)
      except:
        fstr = str(self.get(fn))
        errors.append(fn)
      a.append(fstr)
    if self.virtual:
      a.append("co:Z:GFAPY_virtual_line")
    if errors:
      a.append("# INVALID; errors found in fields: "+
          ",".join(errors))
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
      v = gfapy.Field.to_gfa_field(v, datatype = t, fieldname = fieldname,
                                  line = self)
    if self.vlevel >= 2:
      gfapy.Field.validate_gfa_field(v, t, fieldname)
    return gfapy.Field.to_gfa_tag(v, fieldname, datatype = t, line = self) if tag else v

  def __repr__(self):
    try:
      s = str(self)
    except:
      s = "\t".join([ self.record_type + "(error!)" ] + \
          [ repr(self.get(fn)) for fn in self.positional_fieldnames ] + \
          [ (fn + ":" + self.get_datatype(fn) + ":" + repr(self.get(fn))) for fn in self.tagnames ])
    return "gfapy.Line('{0}',version='{1}',vlevel={2})".format(s,self.version,self.vlevel)

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
