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

  def to_str(self, add_virtual_commentary=True):
    """
    Parameters
    ----------
    add_virtual_commentary : bool
      add a 'co' tag to virtual lines (default: True)

    Returns
    -------
    str
      A string representation of self.
    """
    return gfapy.Line.SEPARATOR.join(self.to_list(
      add_virtual_commentary=add_virtual_commentary))

  def to_list(self, add_virtual_commentary=True):
    """
    Parameters
    ----------
    add_virtual_commentary : bool
      add a 'co' tag to virtual lines (default: True)

    Returns
    -------
    str list
      A list of string representations of the fields.
    """
    a = []
    errors = []
    try:
      rt = self.record_type
    except:
      rt = "<error>"
      errors.append("record_type")
    a.append(rt)
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
    if self.virtual and add_virtual_commentary:
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
      v = gfapy.Field._to_gfa_field(v, datatype = t, fieldname = fieldname,
                                  line = self)
    if self.vlevel >= 2:
      gfapy.Field._validate_gfa_field(v, t, fieldname)
    if tag:
      return gfapy.Field._to_gfa_tag(v, fieldname, datatype = t, line = self)
    else:
      return v

  def __repr__(self):
    try:
      s = str(self)
    except:
      rt = self.record_type + "(error!)"
      s = [ rt ]
      for fn in self.positional_fieldnames:
        try:
          field_s = repr(self.get(fn))
        except:
          field_s = "<error>"
        s.append(field_s)
      for tn in self.tagnames:
        dt = self.get_datatype(tn)
        try:
          tv = repr(self.get(tn))
        except:
          tv = "<ERROR>"
        s.append("{}:{}:{}".format(tn,dt,tv))
      s = "\t".join(s)
    return "gfapy.Line('{0}',version='{1}',vlevel={2})".format(s,self.version,self.vlevel)

  def refstr(self, maxlen=10):
    """String containing a list of lines referencing to this line.

    Parameters
    ----------
    maxlen : int
      Shorten lists longer than the specified value (default: 10)

    Returns
    -------
    str
    """
    andmore = 0
    references = self.all_references
    if len(references) > maxlen:
      andmore = len(references) - 10
      references = references[:10]
    lines_list = "\n".join([str(l) for l in references])
    if andmore > 0:
      lines_list += "\n... ({} more)".format(andmore)
    return lines_list

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
    for of in self.tagnames:
      retval.append([of, self.get_datatype(of), self.get(of)])
    return retval
