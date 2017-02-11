import gfapy

class FieldData:

  @property
  def positional_fieldnames(self):
    """
    Returns
    -------
    str list
      Names of the positional fields.

    .. note::
      These names are not always the field names
      in the specification,
      as these may be implemented as aliases to cope with
      different names for the same content in GFA1 vs GFA2.
    """
    if not self.version:
      raise gfapy.VersionError("Version is not set")
    return self.__class__.POSFIELDS

  @property
  def tagnames(self):
    """
    Returns
    -------
    str list
      Name of the defined tags.
    """
    return [ x for x in self.data.keys() if x not in self.positional_fieldnames ]

  def set(self, fieldname, value):
    """
    Set the value of a field.

    If a datatype for a new custom tag is not set,
    the default for the value assigned to the field will be used
    (e.g. J for Hashes, i for Integer, etc).

    Parameters
    ----------
    fieldname : str
      The name of the field to set.
      (positional field, predefined tag (uppercase) or custom tag (lowercase))

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
    if fieldname in self.data or self._is_predefined_tag(fieldname):
      return self._set_existing_field(fieldname, value)
    elif fieldname in self.__class__.FIELD_ALIAS:
      return self.set(self.__class__.FIELD_ALIAS[fieldname], value)
    elif self.is_virtual():
      raise gfapy.RuntimeError("Virtual lines do not have tags")
    elif (self.vlevel == 0) or self._is_valid_custom_tagname(fieldname):
      self._define_field_methods(fieldname)
      if self.datatype.get(fieldname, None) is not None:
        return self._set_existing_field(fieldname, value)
      elif value is not None:
        self.datatype[fieldname] = gfapy.field.get_default_gfa_tag_datatype(value)
        self.data[fieldname] = value
        return self.data[fieldname]
    else:
      raise gfapy.FormatError(
        "{} is not an existing or predefined field or a ".format(field_name)+
        "valid custom tag")

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
    v = self.data.get(fieldname, None)
    if isinstance(v, str):
      t = self._field_datatype(fieldname)
      if t != "Z" and t != "seq":
        # value was not parsed or was set to a string by the user
        self.data[fieldname] = gfapy.field.parse_gfa_field(v, t,
                                                    safe = (self.vlevel >= 1),
                                                    fieldname = fieldname,
                                                    line = self.data)
        return self.data[fieldname]
      else:
        if (self.vlevel >= 3):
          gfapy.field.validate_gfa_field(v, t, fieldname)
    elif v is not None:
      if (self.vlevel >= 3):
        t = self._field_datatype(fieldname)
        gfapy.field.validate_gfa_field(v, t, fieldname)
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
    if tagname in tagnames:
      self.datatype.delete(tagname)
      return self.data.delete(tagname)
    else:
      return None

  def _set_existing_field(self, fieldname, value, set_reference = False):
    renaming_connected = False
    if self.gfa:
      if not set_reference and \
        (fieldname in self.__class__.REFERENCE_FIELDS or \
         fieldname in self.__class__.REFERENCE_RELATED_FIELDS):
        raise gfapy.RuntimeError(
          "The value of field '{}' cannot be changed".format(fieldname)+
          "as the line belongs to a GFA instance")
      if (fieldname == self.__class__.STORAGE_KEY) or \
        (self.__class__.STORAGE_KEY == "name" and \
        fieldname == self.__class__.NAME_FIELD):
         renaming_connected = True
         self.gfa._unregister_line(self)
    if value is None:
      self.data.delete(fieldname)
    else:
      if self.vlevel >= 3:
        self._field_or_default_datatype(fieldname, value)
        gfapy.field.validate_gfa_field(value, self._field_datatype(fieldname), fieldname)
      self.data[fieldname] = value
    if renaming_connected:
      self.gfa._register_line(self)
