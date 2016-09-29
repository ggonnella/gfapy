import gfapy

def unsafe_decode(string):
  return string

def decode(string):
  validate_encoded(string)
  return string

def validate_encoded(string):
  if string.find("\n") != -1:
    raise gfapy.FormatError("{} is not a single-line string"
                            .format(repr(string)))

validate_decoded = validate_encoded

def unsafe_encode(obj):
  return str(obj)

def encode(obj):
  if isinstance(obj, str):
    validate_encoded(obj)
    return obj
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(object.__class__.__name__)+
      "(accepted classes: str)")
