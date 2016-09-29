import gfapy
def validate_gfa_field(obj, datatype, fieldname = None):
  """
  Validates a non-string python object field content
  according to the field datatype.
  """
  mod = gfapy.field.FIELD_MODULE.get(datatype)
  if not mod:
    raise gfapy.TypeError(
      "Datatype unknown: {}".format(repr(datatype)))
  return mod.validate_decoded(obj)
