import gfapy
import re

def unsafe_decode(string):
  return gfapy.ByteArray(string)

def decode(string):
  return gfapy.ByteArray(string)

def validate_encoded(string):
  if not re.match(r"^[0-9A-F]+$", string):
    raise gfapy.FormatError(
      "{} is not a valid hex string\n".format(repr(string))+
      "(it does not match the regular expression [0-9A-F]+)")

def validate_decoded(byte_array):
  return byte_array.validate()

def unsafe_encode(obj):
  if isinstance(obj, gfapy.ByteArray):
    return str(obj)
  if isinstance(obj, list):
    return str(gfapy.ByteArray(obj))
  elif isinstance(obj, str):
    return obj
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str, list, gfapy.ByteArray)")

def encode(obj):
  if isinstance(obj, gfapy.ByteArray):
    return str(obj)
  elif isinstance(obj, list):
    return str(gfapy.ByteArray(obj))
  elif isinstance(obj, str):
    validate_encoded(obj)
    return obj
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str, list, gfapy.ByteArray)")
