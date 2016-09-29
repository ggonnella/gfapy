import gfapy
import re

def unsafe_decode(string):
  return string

def decode(string):
  validate_encoded(string)
  return string

def validate_encoded(string):
  if not re.match(r"^[!-~]+$", string):
    raise gfapy.FormatError(
      "{} is not a valid custom record type\n".format(repr(string)) +
      "(it contains spaces and/or non-printable characters)")
  elif string in ["E", "G", "F", "O", "U", "H", "#", "S"]:
    raise gfapy.FormatError(
      "{} is not a valid custom record type\n".format(repr(string)) +
      "(it is a predefined GFA2 record type)")

validate_decoded = validate_encoded

def unsafe_encode(obj):
  return str(obj)

def encode(obj):
  if isinstance(obj, str):
    validate_encoded(obj)
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__) +
      "(accepted classes: str)")
  return obj
