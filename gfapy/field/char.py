import gfapy
import re

def decode(string):
  validate_encoded(string)
  return string

unsafe_decode = decode

def validate_encoded(string):
  if not re.match(r"^[!-~]$", string):
    raise gfapy.FormatError(
        "{} is not a single printable character string".format(repr(string)))

def validate_decoded(string):
  return validate_encoded(string)

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
