import gfapy

class FieldData:

  @property
  def positional_fieldnames(self):
    """Name of the positional fields.
    Returns:
      str list

    Note:
      The field names can vary from the exact name of the
      fields in the specification, due to compatibility issues.
    """
    return self.__class__.POSFIELDS

  @property
  def tagnames(self):
    """Names of the tags defined in the line.
    Returns:
      str list
    """
    return [ x for x in self._data.keys() \
        if x not in self.positional_fieldnames ]

  @property
  def record_type(self):
    """The record type.

    The content of the first field of the line. In all predefined record types
    this is a single-letter upper case string.

    Returns:
      str
    """
    return self.__class__.RECORD_TYPE

  def set(self, fieldname, value):
    """Set the value of a field.

    If a datatype for a new custom tag is not set,
    the default for the value assigned to the field will be used
    (e.g. J for Hashes, i for Integer, etc).

    Parameters
    ----------
    fieldname : str
      The name of the field to set.
      (positional field, predefined or custom tag)

    Raises
    ------
    gfapy.FormatError
      If **fieldname** is not a valid predefined or
      custom tag name (and **validate["tags"]**).

    Returns
    -------
    object
      **value**
    """
    if fieldname in self._data or self._is_predefined_tag(fieldname):
      return self._set_existing_field(fieldname, value)
    elif fieldname in self.__class__.FIELD_ALIAS:
      return self.set(self.__class__.FIELD_ALIAS[fieldname], value)
    elif self.virtual:
      raise gfapy.RuntimeError("Virtual lines do not have tags")
    elif (self.vlevel == 0) or self._is_valid_custom_tagname(fieldname):
      self._define_field_methods(fieldname)
      if self._datatype.get(fieldname, None) is not None:
        return self._set_existing_field(fieldname, value)
      elif value is not None:
        self._datatype[fieldname] = \
            gfapy.Field._get_default_gfa_tag_datatype(value)
        self._data[fieldname] = value
        return self._data[fieldname]
    else:
      raise gfapy.FormatError(
        "{} is not a positional field,".format(fieldname)+
        "an existing tag, an alias, a predefined tag or a valid custom tag\n"+
        "positional fields: {}\n".format(", ".join(self.positional_fieldnames))+
        "existing tags: {}\n".format(", ".join(self.tagnames))+
        "aliases: {}\n".format(", ".join(self.__class__.FIELD_ALIAS.keys()))+
        "predefined tags: {}\n".format(", ".join(self.__class__.PREDEFINED_TAGS)))

  def get(self, fieldname):
    """
    Get the value of a field.

    Parameters
    ----------
    fieldname : str
      Name of the field.

    Returns
    -------
    object or None
      Value of the field or **None** if field is not defined.
    """
    v = self._data.get(fieldname, None)
    if isinstance(v, str):
      t = self._field_datatype(fieldname)
      if t != "Z" and t != "seq":
        # value was not parsed or was set to a string by the user
        self._data[fieldname] = gfapy.Field._parse_gfa_field(v, t,
                                                    safe = (self.vlevel >= 1),
                                                    fieldname = fieldname,
                                                    line = self)
        return self._data[fieldname]
      else:
        if (self.vlevel >= 3):
          gfapy.Field._validate_gfa_field(v, t, fieldname)
    elif v is not None:
      if (self.vlevel >= 3):
        t = self._field_datatype(fieldname)
        gfapy.Field._validate_gfa_field(v, t, fieldname)
    else:
      dealiased_fieldname = self.__class__.FIELD_ALIAS.get(fieldname, None)
      if dealiased_fieldname is not None:
        return self.get(dealiased_fieldname)
    return v

  def try_get(self, fieldname):
    """
    Value of a field, raising an exception if it is not defined.

    Parameters
    ----------
    fieldname : str
      Name of the field.

    Raises
    ------
    gfapy.NotFoundError
      If field is not defined.

    Returns
    -------
    object or None
      Value of the field.
    """
    v = self.get(fieldname)
    if v is None:
      raise gfapy.NotFoundError(
        "No value defined for tag {}".format(fieldname))
    return v

  def delete(self, tagname):
    """
    Remove a tag from the line, if it exists; do nothing if it does not.

    Parameters
    ----------
    tagname : Symbol
      The tag name of the tag to remove.

    Returns
    -------
    object or None
      The deleted value or None, if the field was not defined.
    """
    if tagname in self.tagnames:
      if tagname in self._datatype:
        self._datatype.pop(tagname)
      return self._data.pop(tagname)
    else:
      return None

  def _set_existing_field(self, fieldname, value, set_reference = False):
    renaming_connected = False
    if self._gfa:
      if not set_reference and \
        (fieldname in self.__class__.REFERENCE_FIELDS or \
         fieldname in self.__class__.BACKREFERENCE_RELATED_FIELDS):
        raise gfapy.RuntimeError(
          "The value of field '{}' cannot be changed, ".format(fieldname)+
          "as the line belongs to a GFA instance")
      if (fieldname == self.__class__.STORAGE_KEY) or \
        (self.__class__.STORAGE_KEY == "name" and \
        fieldname == self.__class__.NAME_FIELD):
         renaming_connected = True
         self._gfa._unregister_line(self)
    if value is None:
      if fieldname in self._data:
        self._data.pop(fieldname)
    else:
      if self.vlevel >= 3:
        self._field_or_default_datatype(fieldname, value)
        gfapy.Field._validate_gfa_field(value, self._field_datatype(fieldname),
            fieldname)
      self._data[fieldname] = value
    if renaming_connected:
      self._gfa._register_line(self)

  def _dealias_fieldname(self, fieldname):
    return self.__class__.FIELD_ALIAS.get(fieldname, fieldname)

  def _dealias_fieldnames(self, fieldnames):
    fieldnames[:] = map(self._dealias_fieldname, fieldnames)
