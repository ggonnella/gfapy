import gfapy
import re

def unsafe_decode(string):
  return [ gfapy.OrientedLine(str(l[0:-1]), str(l[-1]))
           for l in string.split(" ")]

def decode(string):
  validate_encoded(string)
  return unsafe_decode(string)

def validate_encoded(string):
  if not re.match(r"^[!-~]+[+-]( [!-~][+-])*$", string):
    raise gfapy.FormatError(
      "{} is not a valid list of GFA2 segment names ".format(repr(string))+
      "and orientations")

def validate_decoded(iterable):
  for elem in iterable:
    elem = gfapy.OrientedLine(elem)
    elem.validate()
    if not re.match(r"^[!-~]+$", elem.name):
      raise gfapy.FormatError(
        "#{elem.name} is not a valid GFA2 segment name\n".format(elem.name)+
        "(it does not match [!-~]+)")
    if not elem.orient in ["+", "-"]:
      raise gfapy.FormatError(
        "#{elem.orient} is not a valid orientation")

def unsafe_encode(obj):
  if isinstance(obj, str):
    return obj
  elif isinstance(obj, list):
    return " ".join([str(gfapy.OrientedLine(os)) for os in obj])
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str, list)")

def encode(obj):
  validate_decoded(obj)
  return unsafe_encode(obj)
