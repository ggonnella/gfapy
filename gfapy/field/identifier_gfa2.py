import gfapy
import re

def unsafe_decode(string):
  return string

def decode(string):
  validate_encoded(string)
  return string

def validate_encoded(string):
  if not re.match("^[!-~]+$", string):
    raise gfapy.FormatError(
      "{} is not a valid GFA2 identifier\n".format(repr(string))+
      "(it contains spaces or non-printable characters)")

def validate_decoded(obj):
  if isinstance(obj, gfapy.Line):
    validate_encoded(obj.name)
  elif isinstance(obj, str):
    validate_encoded(obj)
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str, gfapy.Line)")

def unsafe_encode(obj):
  if isinstance(obj, str):
    return obj
  if isinstance(obj, gfapy.Line):
    return str(obj.name)
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str, gfapy.Line)")

def encode(obj):
  string = unsafe_encode(obj)
  validate_encoded(string)
  return string
