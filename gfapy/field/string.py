import gfapy
import re

def decode(string):
  validate_encoded(string)
  return string

def unsafe_decode(string):
  return string

def validate_encoded(string):
  if not re.match("^[ !-~]+$", string):
    raise gfapy.FormatError(
      "{} is not a valid string field\n".format(repr(string))+
      "(it contains newlines/tabs and/or non-printable characters)")

validate_decoded = validate_encoded

def unsafe_encode(obj):
  return str(obj)

def encode(obj):
  if not isinstance(obj, str):
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str)")
  validate_encoded(obj)
  return obj
