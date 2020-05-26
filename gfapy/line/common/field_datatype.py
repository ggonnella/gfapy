import gfapy

class FieldDatatype:

  def get_datatype(self, fieldname):
    """
    Returns a string, which specifies the datatype of a field.

    Parameters
    ----------
    fieldname : str
      The tag name of the field.

    Returns
    -------
    str
      The datatype symbol.
      (One of gfapy.Field.FIELD_DATATYPE)
    """
    fieldname = self.__class__.FIELD_ALIAS.get(fieldname, fieldname)
    return self._field_or_default_datatype(fieldname,
        self._data.get(fieldname,None))

  def set_datatype(self, fieldname, datatype):
    """
    Set the datatype of a tag.

    If an existing tag datatype is changed, its content may become
    invalid (call **validate_field** if necessary).

    Parameters
    ----------
    fieldname : str
      The field name (it is not required that the field exists already)
    datatype : gfapy.Field.FIELD_DATATYPE
      The datatype.

    Raises
    ------
    gfapy.ArgumentError
      If **datatype** is not a valid datatype for tags.
    """
    if self._is_predefined_tag(fieldname):
      if self.get_datatype(fieldname) != datatype:
        raise gfapy.RuntimeError(
          "Cannot set the datatype of {} to {}\n".format(fieldname, datatype)+
          "The datatype of a predefined tag cannot be changed")
    elif not self._is_valid_custom_tagname(fieldname) and self.vlevel > 0:
      raise gfapy.FormatError(
        "{} is not a valid custom tag name".format(fieldname))
    if datatype not in gfapy.Field.TAG_DATATYPE:
      raise gfapy.ArgumentError("Unknown datatype: {}".format(datatype))
    self._datatype[fieldname] = datatype

  def _field_datatype(self, fieldname):
    return self._datatype.get(fieldname,
        self.__class__.DATATYPE.get(fieldname, None))

  def _field_or_default_datatype(self, fieldname, value):
    t = self._field_datatype(fieldname)
    if t is None:
      if value is None:
        return None
      t = gfapy.Field._get_default_gfa_tag_datatype(value)
      self._datatype[fieldname] = t
    return t
