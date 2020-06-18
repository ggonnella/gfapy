import re
import gfapy

class Validate:

  def validate_field(self, fieldname):
    """
    Raises an error if the content of the field does not correspond to
    the field type.

    Parameters
    ----------
    fieldname : str
      The tag name of the field to validate.

    Raises
    ------
    gfapy.FormatError
      If the content of the field is not valid, according to its required type.
    """
    fieldname = self.__class__.FIELD_ALIAS.get(fieldname, fieldname)
    v = self._data[fieldname]
    t = self._field_or_default_datatype(fieldname, v)
    gfapy.Field._validate_gfa_field(v, t, fieldname)

  def validate(self):
    """
    Validate the gfapy.Line instance.

    Raises
    ------
    gfapy.FormatError
      If any field content is not valid.
    """
    fieldnames = self.positional_fieldnames + self.tagnames
    if self.vlevel == 0:
      self._validate_tagnames_and_types()
    for fieldname in fieldnames:
      self.validate_field(fieldname)
    self._validate_record_type_specific_info()

  def _validate_tagnames_and_types(self):
    for n in self.tagnames:
      if self._is_predefined_tag(n):
        self._validate_predefined_tag_type(n, self._field_datatype(n))
      elif not self._is_valid_custom_tagname(n):
        raise gfapy.FormatError("Custom tag names must consist in a letter "+
            "and a digit or two letters\nFound: {}".format(n))

  def _validate_predefined_tag_type(self, tagname, datatype):
    if datatype != self.__class__.DATATYPE[tagname]:
      raise gfapy.TypeError(
        "Tag {} must be of type ".format(tagname) +
        "{}, {} found".format(self.__class__.DATATYPE[tagname], datatype))

  def _validate_custom_tagname(self, tagname):
    if not self._is_valid_custom_tagname(tagname):
      raise gfapy.FormatError("Custom tag names must consist in a letter "+
          "and a digit or two letters\nFound: {}".format(tagname))

  @staticmethod
  def _is_valid_custom_tagname(tagname):
    return (re.match(r"^[A-Za-z][A-Za-z0-9]$", tagname))

  def _validate_record_type_specific_info(self):
    pass

  def _is_predefined_tag(self, fieldname):
    return fieldname in self.__class__.PREDEFINED_TAGS

