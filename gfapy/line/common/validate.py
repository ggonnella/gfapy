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
    gfapy.field.validate_gfa_field(v, t, fieldname)

  def validate(self):
    """
    Validate the gfapy.Line instance.

    Raises
    ------
    gfapy.FormatError
      If any field content is not valid.
    """
    fieldnames = positional_fieldnames + tagnames
    for fieldname in fieldnames:
      self.validate_field(fieldname)
    self._validate_record_type_specific_info()

  def is_valid_custom_tagname(self, fieldname):
    return (re.match(r"^[a-z][a-z0-9]$", fieldname))

  def _validate_record_type_specific_info(self):
    pass

  def _predefined_tag(self, fieldname):
    return fieldname in self.__class__.PREDEFINED_TAGS
