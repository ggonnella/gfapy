import gfapy

def unsafe_decode(string):
  return gfapy.Alignment(string, valid = True, version = "gfa2")

def decode(string):
  return gfapy.Alignment(string, valid = False, version = "gfa2")

validate_encoded = decode

def validate_decoded(alignment):
  alignment.validate()

def unsafe_encode(obj):
  return str(obj)

def encode(obj):
  if isinstance(obj, str):
    validate_encoded(obj)
    return obj
  elif isinstance(obj, gfapy.CIGAR) or isinstance(obj, gfapy.Trace):
    obj.validate()
    return str(obj)
  elif isinstance(obj, gfapy.Placeholder):
    return "*"
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: "+
      "str, CIGAR, Trace, AlignmentPlaceholder)")

