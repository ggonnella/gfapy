import gfapy

def validate_encoded_gfa_field(obj, datatype, fieldname = None):
  """
  Validates a GFA string representation according to the field datatype.

  Parameters
  ----------
  obj : object
    the object to validate
  datatype : one of gfapy.field.FIELD_DATATYPE
  	the datatype to use
  fieldname : str, optional
  	fieldname for error messages

  Raises
  ------
  gfapy.FormatError
  	if the object type or content
    is not compatible to the provided datatype
  gfapy.TypeError
  	if an unknown datatype is specified
  """
  mod = gfapy.Field.FIELD_MODULE.get(datatype)
  if not mod:
    raise gfapy.TypeError(
      "Datatype unknown: {}".format(repr(datatype)))
  return mod.validate_encoded(obj)
