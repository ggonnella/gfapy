import gfapy
import re

def unsafe_decode(string):
  try:
    return int(string)
  except:
    raise gfapy.FormatError(
      "{} does not represent a valid integer".format(repr(string)))

def decode(string):
  value = unsafe_decode(string)
  validate_decoded(value)
  return value

def validate_decoded(integer):
  if integer < 0:
    raise gfapy.ValueError(
      "{} is not a positive integer".format(integer))

def validate_encoded(string):
  if not re.match(r"^[0-9]+$", string):
    raise gfapy.FormatError(
      "{} does not represent a valid unsigned integer".format(repr(string)))

def unsafe_encode(obj):
  return str(obj)

def encode(obj):
  if isinstance(obj, str):
    validate_encoded(obj)
    return obj
  elif isinstance(obj, int):
    validate_decoded(obj)
    return str(obj)
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str, int)")
