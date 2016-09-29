import gfapy
import re

def unsafe_decode(string):
  return string

def decode(string):
  validate_encoded(string)
  return string

def validate_encoded(string):
  if not re.match("^[!-)+-<>-~][!-~]*$", string):
    raise gfapy.FormatError(
      "{} is not a valid GFA1 path name\n".format(repr(string)) +
      "(it does not match the regular expression [!-)+-<>-~][!-~]*")

def validate_decoded(obj):
  if isinstance(obj, str):
    validate_encoded(object)
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str)")

def unsafe_encode(obj):
  if isinstance(obj, str):
    return obj
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str)")

def encode(obj):
  string = unsafe_encode(obj)
  validate_encoded(string)
  return string
