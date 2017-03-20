import gfapy
import re

def unsafe_decode(string):
  return [ gfapy.Alignment(s, version = "gfa1", valid = True) \
             for s in string.split(",") ]

def decode(string):
  validate_encoded(string)
  return unsafe_decode(string)

def validate_encoded(string):
  if not re.match(r"^(\*|(([0-9]+[MIDNSHPX=])+))(,(\*|(([0-9]+[MIDNSHPX=])+)))*$", string):
     raise gfapy.FormatError(
       "{} is not a comma separated list of * or CIGARs\n".format(repr(string))+
       "(CIGAR strings must match ([0-9]+[MIDNSHPX=])+)")

def validate_decoded(obj):
  if isinstance(obj, gfapy.Placeholder):
    pass
  elif isinstance(obj, list):
    for e in obj:
      e = gfapy.Alignment(e, version = "gfa1")
      e.validate()
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n".format(obj.__class__.__name__)+
      "(accepted classes: list, AlignmentPlaceholder)")

def unsafe_encode(obj):
  if isinstance(obj, gfapy.Placeholder):
    return str(obj)
  elif isinstance(obj, list):
    return ",".join([str(gfapy.Alignment(cig)) for cig in obj])
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: list, AlignmentPlaceholder)")

def encode(obj):
  if isinstance(obj, gfapy.Placeholder):
    return str(obj)
  if isinstance(obj, list):
    def f(cig):
      cig = gfapy.Alignment(cig)
      cig.validate()
      return str(cig)
    return ",".join(map(f, obj))
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: list, AlignmentPlaceholder)")
