import gfapy
import re

def decode(string):
  try:
    return int(string)
  except:
    raise gfapy.FormatError("the string does not represent a valid integer")

unsafe_decode = decode

def validate_decoded(obj):
  if isinstance(obj, int):
    pass
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str, int)")

def validate_encoded(string):
  if not re.match("^[-+]?[0-9]+$", string):
    raise gfapy.FormatError(
      "{} does not represent a valid integer\n".format(repr(string)) +
      "(it does not match the regular expression [-+]?[0-9]+)")

def unsafe_encode(obj):
  return str(obj)

def encode(obj):
  if isinstance(obj, str):
    validate_encoded(obj)
    return obj
  elif isinstance(obj, int):
    return str(obj)
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str, int)")
