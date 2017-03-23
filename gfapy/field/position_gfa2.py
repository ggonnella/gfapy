import gfapy
import re

def unsafe_decode(string):
  return gfapy.LastPos(string)

def decode(string):
  position = unsafe_decode(string)
  value = gfapy.posvalue(position)
  if value < 0:
    raise gfapy.ValueError(
      "{} is not a positive integer".format(value))
  return position

def validate_decoded(obj):
  if isinstance(obj, int):
    if obj < 0:
      raise gfapy.ValueError(
        "{} is not a positive integer".format(obj))
  elif isinstance(obj, gfapy.LastPos):
    obj.validate()
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: int, gfapy.LastPos)")

def validate_encoded(string):
  if not re.match(r"^[0-9]+\$?$", string):
    raise gfapy.FormatError(
      "{} is not a valid GFA2 position\n".format(repr(string))+
      "(it must be an unsigned integer eventually followed by a $)")

def unsafe_encode(obj):
  return str(obj)

def encode(obj):
  if isinstance(obj, str):
    validate_encoded(obj)
  else:
    validate_decoded(obj)
  return str(obj)
