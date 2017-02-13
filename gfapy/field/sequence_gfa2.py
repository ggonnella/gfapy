import gfapy
import re

def unsafe_decode(string):
  if string == "*":
    return gfapy.Placeholder()
  else:
    return string

def decode(string):
  obj = unsafe_decode(string)
  validate_decoded(obj)
  return obj

def validate_encoded(string):
  if not re.match(r"^[!-~]+$", string):
    raise gfapy.FormatError(
      "the string {} is not a valid GFA2 sequence\n".format(repr(string))+
      "(it contains spaces and/or non-printable characters)")

def validate_decoded(obj):
  if isinstance(obj, gfapy.Placeholder):
    pass
  elif isinstance(obj, str):
    validate_encoded(obj)
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str, gfapy.Placeholder)")

def unsafe_encode(obj):
  return str(obj)

def encode(obj):
  if isinstance(obj, gfapy.Placeholder):
    return str(obj)
  elif isinstance(obj, str):
    validate_encoded(obj)
    return obj
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str, gfapy.Placeholder)")
