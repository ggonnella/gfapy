import gfapy

def unsafe_decode(string):
  return string

def decode(string):
  validate_decoded(string)
  return string

def validate_decoded(string):
  if string != "+" and string != "-":
    raise gfapy.FormatError(
      "{} is not a valid orientation\n".format(repr(string))+
      "(it must be + or -)")
  return string

#identical to validate_decoded, because python version uses strings for symbols
def validate_encoded(string):
  if string != "+" and string != "-":
    raise gfapy.FormatError(
      "{} is not a valid orientation\n".format(repr(string))+
      "(it must be + or -)")
  return string

def unsafe_encode(obj):
  return str(obj)

def encode(obj):
  if isinstance(obj, str):
    validate_encoded(obj)
    return obj
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str)")
