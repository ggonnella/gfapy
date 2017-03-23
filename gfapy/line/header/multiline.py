import gfapy

class Multiline:
  """
  Implementation of the support for multiple header line in the
  GFA file (which also may contain the same value defined multiple
  times in different lines).
  """

  SINGLE_DEFINITION_TAGS = ["VN", "TS"]

  def add(self, tagname, value, datatype = None):
    """
    Set a header value (multi-value compatible).

    If a field does not exist yet, set it to value. If it exists and it is a
    *gfapy.FieldArray*, add the value to the field array. If it exists and it
    is not a field array, create a field array with the previous value and
    the new one.

    Parameters
    ----------
    tagname : str
    value : object
    datatype : gfapy.Field.TAG_DATATYPE, optional
      The datatype to use.
      The default is to determine the datatype according to the value or the
      previous values present in the field.
    """
    prev = self.get(tagname)
    if prev is None:
      if datatype is not None:
        self.set_datatype(tagname, datatype)
      self.set(tagname, value)
      return
    elif not isinstance(prev, gfapy.FieldArray):
      if tagname in self.SINGLE_DEFINITION_TAGS:
        if self.field_to_s(tagname) == \
            gfapy.Field._to_gfa_field(value, fieldname=tagname):
          return
        else:
          raise gfapy.InconsistencyError(
            "Inconsistent values for header tag {} found\n".format(tagname)+
            "Previous definition: {}\n".format(prev)+
            "Current definition: {}".format(value))
      prev = gfapy.FieldArray(self.get_datatype(tagname), [prev])
      self._set_existing_field(tagname, prev)
    if self.vlevel > 1:
      prev.vpush(value, datatype, tagname)
    else:
      prev.append(value)

  def field_to_s(self, fieldname, tag = False):
    """
    Compute the string representation of a field.

    Parameters
    ----------
    fieldname : str
      The tag name of the field.
    tag : bool
      *(defaults to: ***False***)*
      Return the 'tagname:datatype:value' representation.

    Raises
    ------
    gfapy.NotFoundError
      If field is not defined.

    Returns
    -------
    str
      The string representation.
    """
    prev = self.get(fieldname)
    if isinstance(prev, gfapy.FieldArray):
      if self.vlevel >= 2:
        prev._validate_gfa_field(None, fieldname)
      return prev._to_gfa_tag(fieldname=fieldname) if tag else \
             prev._to_gfa_field(fieldname=fieldname)
    else:
      return super(gfapy.line.header.Line, self).field_to_s(fieldname, tag)

  def _n_duptags(self):
    n = 0
    for tn in self.tagnames:
      if isinstance(self.get(tn),gfapy.FieldArray):
        n+=1
    return n

  def _split(self):
    """
    Split the header line into single-tag lines.

    If a tag is a FieldArray, this is splitted into multiple fields
    with the same fieldname.

    Returns
    -------
    gfapy.line.Header list
    """
    retval = []
    for tagname, datatype, value in self._tags():
      h = gfapy.line.Header(["H"], vlevel = self.vlevel)
      h.set_datatype(tagname, datatype)
      h.set(tagname, value)
      retval.append(h)
    return retval

  def _merge(self, gfa_line):
    """
    Merge an additional **gfa.line.Header** line into this header line.

    Parameters
    ----------
    gfa_line : gfapy.line.Header
      The header line to merge.

    Returns
    -------
    self
    """
    for of in gfa_line.tagnames:
      self.add(of, gfa_line.get(of), gfa_line.get_datatype(of))
    return self

  def _tags(self):
    """
    List of tags data.

    Returns the tags as an list of [fieldname, datatype, value]
    lists. If a field is a FieldArray, this is splitted into multiple fields
    with the same fieldname.

    Returns
    -------
    (str, str, object) list
    """
    retval = []
    for of in self.tagnames:
      value = self.get(of)
      if isinstance(value, gfapy.FieldArray):
        for elem in value:
          retval.append((of, value.datatype, elem))
      else:
        retval.append((of, self.get_datatype(of), value))
    return retval
