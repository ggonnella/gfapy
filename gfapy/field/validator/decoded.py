import gfapy
def validate_decoded_gfa_field(obj, datatype, fieldname = None):
  """
  Validates a non-string python object field content
  according to the field datatype.
  """
  if isinstance(obj, gfapy.FieldArray):
    return obj._validate_gfa_field(datatype, fieldname=fieldname)
  mod = gfapy.Field.FIELD_MODULE.get(datatype)
  if not mod:
    raise gfapy.TypeError(
      "Datatype unknown: {}".format(repr(datatype)))
  return mod.validate_decoded(obj)
