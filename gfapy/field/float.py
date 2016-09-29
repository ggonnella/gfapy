import gfapy
import re

def decode(string):
  try:
    return float(string)
  except:
    raise gfapy.FormatError

unsafe_decode = decode

def validate_decoded(integer):
  pass
  # always valid

def validate_encoded(string):
  if not re.match(r"^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$", string):
    raise gfapy.FormatError(
      "{} does not represent a valid float\n".format(repr(string)) +
      "(it does not match [-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)")

def unsafe_encode(obj):
  return str(obj)


def encode(obj):
  if isinstance(obj, str):
    validate_encoded(obj)
    return obj
  elif isinstance(obj, int) or isinstance(obj, float):
    return str(obj)
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str, int, float)")
