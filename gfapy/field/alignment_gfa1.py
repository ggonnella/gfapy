import gfapy
import re

def decode(string):
  return gfapy.Alignment(string, valid = False, version = "gfa1")

def unsafe_decode(string):
  return gfapy.Alignment(string, valid = True, version = "gfa1")

def validate_encoded(string):
  if not re.match(r"^(\*|([0-9]+[MIDNSHPX=])+)$", string):
    raise gfapy.FormatError(
      "{} is not a valid GFA1 alignment\n".format(repr(string)) +
      "(it is not * and is not a CIGAR string (([0-9]+[MIDNSHPX=])+)")

def validate_decoded(obj):
  if isinstance(obj, gfapy.CIGAR):
    obj.validate()
  elif isinstance(obj, gfapy.Placeholder):
    pass
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name) +
      "(accepted classes: gfapy.CIGAR, gfapy.Placeholder)")

def unsafe_encode(obj):
  return str(obj)

def encode(obj):
  if isinstance(obj, str):
    validate_encoded(obj)
    return obj
  elif isinstance(obj, gfapy.CIGAR):
    obj.validate()
    return str(obj)
  elif isinstance(obj, gfapy.Placeholder):
    return str(obj)
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__) +
      "(accepted classes: str, gfapy.CIGAR, gfapy.Placeholder)")
