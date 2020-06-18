import gfapy
import re

def unsafe_decode(string):
  if string == "*":
    return gfapy.Placeholder()
  else:
    return string

def decode(string):
  if string == "*":
    return gfapy.Placeholder()
  else:
    validate_encoded(string)
    return string

def validate_encoded(string):
  if not re.match("^[!-~]+$", string):
    raise gfapy.FormatError(
      "{} is not a valid GFA2 optional identifier\n".format(repr(string))+
      "(it contains spaces or non-printable characters)")

def validate_decoded(obj):
  if isinstance(obj, gfapy.Placeholder):
    pass
  elif isinstance(obj, gfapy.Line):
    validate_encoded(obj.name)
  elif isinstance(obj, str):
    validate_encoded(obj)
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str, gfapy.Line, gfapy.Placeholder)")

def unsafe_encode(obj):
  if isinstance(obj, str):
    return obj
  elif isinstance(gfapy.Placeholder):
    return str(obj)
  elif isinstance(obj, gfapy.Line):
    return str(obj.name)
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str, gfapy.Line, gfapy.Placeholder)")

def encode(obj):
  if isinstance(obj, gfapy.Placeholder):
    return str(obj)
  elif isinstance(obj, str):
    obj = str(obj)
  elif isinstance(obj, gfapy.Line):
    obj = str(obj.name)
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str, gfapy.Line, gfapy.Placeholder)")
  validate_encoded(obj)
  return obj
