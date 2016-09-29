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
    return self._field_or_default_datatype(fieldname, self.data[fieldname])

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

    Returns
    -------
    gfapy.Field.FIELD_DATATYPE
      The datatype.
    """
    if self._predefined_tag(fieldname):
      if get_datatype(fieldname) != datatype:
        raise gfapy.RuntimeError(
          "Cannot set the datatype of {} to {}\n".format(fieldname, datatype)+
          "The datatype of a predefined tag cannot be changed")
    elif not self.is_valid_custom_tagname(fieldname) and self.validate > 0:
      raise gfapy.FormatError(
        "{} is not a valid custom tag name".format(fieldname))
    if datatype not in gfapy.field.TAG_DATATYPE:
      raise gfapy.ArgumentError("Unknown datatype: {}".format(datatype))
    self.datatype[fieldname] = datatype
    return datatype


  def _field_datatype(self, fieldname):
    return self.datatype.get(fieldname, self.__class__.DATATYPE.get(fieldname, None))

  def _field_or_default_datatype(self, fieldname, value):
    t = self._field_datatype(fieldname)
    if t is None:
      if value is None:
        return None
      t = gfapy.field.get_default_gfa_tag_datatype(value)
      self.datatype[fieldname] = t
    return t
