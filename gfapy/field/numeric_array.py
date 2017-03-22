import gfapy
import re

def unsafe_decode(string):
  return gfapy.NumericArray.from_string(string, valid = True)

def decode(string):
  return gfapy.NumericArray.from_string(string)

def validate_encoded(string):
  if not re.match(r"^(f(,[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)+|[CSI](,\+?[0-9]+)+|[csi](,[-+]?[0-9]+)+)$", string):
    raise gfapy.FormatError(
      "{} is not a valid numeric array string\n".format(repr(string))+
      "(it must be one of [fcsiCSI] followed by a comma-separated list of:"+
      " for f: floats; for csi: signed integers; for CSI: unsigned integers)")

def validate_decoded(numeric_array):
  numeric_array.validate()

def unsafe_encode(obj):
  if isinstance(obj, gfapy.NumericArray):
    return str(obj)
  elif isinstance(obj, list):
    return str(gfapy.NumericArray(obj))
  elif isinstance(obj, str):
    return obj
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str, line, gfapy.NumericArray)")

def encode(obj):
  if isinstance(obj, gfapy.NumericArray):
    return str(obj)
  elif isinstance(obj, list):
    return str(gfapy.NumericArray(obj))
  elif isinstance(obj, str):
    validate_encoded(obj)
    return obj
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str, line, gfapy.NumericArray)")
