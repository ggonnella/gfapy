import gfapy

class Validator:

  @staticmethod
  def _validate_gfa_field(obj, datatype, fieldname = None):
    """Validate the content of a field of a Line instance.

    Parameters:
      obj: the value to be validated. It can be either a string (in which case
        the encoded validation method is used) or any other kind of Python
        object (in which case the decoded validation method is used).
      datatype (str) : the name of the datatype to be used for the validation.
        The datatype name is used for the lookup in the FIELD_MODULE dictiorary
        and the validation method of the returned class is used.
      fieldname (str) : optional, for error messages

    Raises:
      gfapy.error.FormatError : if the format of the string representation is
        invalid; or the object contains strings with an invalid format
      gfapy.error.ValueError : if the value of the decoded field is invalid
      gfapy.error.TypeError : if the specified datatype is not defined or
        if the type of the decoded field is invalid
      gfapy.error.VersionError : if the value is invalid for the GFA version
        for which the datatype is specified
    """
    if isinstance(obj, str):
      Validator.__validate_encoded_gfa_field( obj, datatype, fieldname)
    else:
      Validator.__validate_decoded_gfa_field( obj, datatype, fieldname)

  @staticmethod
  def __validate_decoded_gfa_field(obj, datatype, fieldname = None):
    """Validate a non-string field content.

    Parameters:
      obj : the field content to validate
      datatype (str) : the datatype identifier
      fieldname (str) : for error messages

    Raises:
      gfapy.error.TypeError: if the specified datatype is invalid or the
        object is of a class which is not compatible with the datatype
      gfapy.error.FormatError: if the format of a string in the object
        is not compatible with the datatype; or if the object encoded into
        a GFA string is incompatible with the specification
      gfapy.error.VersionError: if the object value is invalid
        for the specific GFA version for which this datatype is used
      gfapy.error.ValueError: if the value of the object is invalid
    """
    if isinstance(obj, gfapy.FieldArray):
      return obj._validate_gfa_field(datatype, fieldname=fieldname)
    mod = gfapy.Field.FIELD_MODULE.get(datatype)
    if not mod:
      raise gfapy.TypeError(
        "Datatype unknown: {}".format(repr(datatype)))
    return mod.validate_decoded(obj)

  @staticmethod
  def __validate_encoded_gfa_field(obj, datatype, fieldname = None):
    """Validate a string field content.

    Parameters:
      obj (str): the field content to validate
      datatype (str) : the datatype identifier
      fieldname (str) : for error messages

    Raises:
      gfapy.error.TypeError: if the specified datatype is invalid
      gfapy.error.FormatError: if the format of the string is invalid
        for the specified datatype
      gfapy.error.VersionError: if the format of the string is invalid
        for the specific GFA version for which this datatype is used
      gfapy.error.ValueError: if the format of the string is valid,
        but the value encoded by the string is invalid
    """
    mod = gfapy.Field.FIELD_MODULE.get(datatype)
    if not mod:
      raise gfapy.TypeError(
        "Datatype unknown: {}".format(repr(datatype)))
    return mod.validate_encoded(obj)
