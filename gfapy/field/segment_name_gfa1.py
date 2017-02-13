import gfapy
import re

def unsafe_decode(string):
  return string


def decode(string):
  validate_encoded(string)
  return string


def validate_encoded(string):
  if not re.match(r"^[!-)+-<>-~][!-~]*$", string):
    raise gfapy.FormatError(
      "{} is not a valid GFA1 segment name\n".format(repr(string))+
      "(it does not match the regular expression [!-)+-<>-~][!-~]*")
  elif re.search(r"[+-],", string):
    raise gfapy.FormatError(
      "{} is not a valid GFA1 segment name\n".format(repr(string))+
      "(it contains + or - followed by ,)")

def validate_decoded(obj):
  if isinstance(obj, gfapy.line.segment.GFA1):
    validate_encoded(obj.name)
  elif isinstance(obj, str):
    validate_encoded(obj)
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str, gfapy.line.segment.GFA1)")

def unsafe_encode(obj):
  if isinstance(obj, str):
    return obj
  elif isinstance(obj, gfapy.line.segment.GFA1):
    return obj.name
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str, gfapy.line.segment.GFA1)")

def encode(obj):
  string = unsafe_encode(obj)
  validate_encoded(string)
  return string
