import gfapy
import re

def unsafe_decode(string):
  return [ gfapy.OrientedLine(str(l[0:-1]), str(l[-1]))
           for l in string.split(" ")]

def decode(string):
  validate_encoded(string)
  return unsafe_decode(string)

def validate_encoded(string):
  if not re.match(r"^[!-~]+[+-]( [!-~]+[+-])*$", string):
    raise gfapy.FormatError(
      "{} is not a valid list of GFA2 segment names ".format(repr(string))+
      "and orientations")

def validate_decoded(iterable):
  for elem in iterable:
    if not isinstance(elem, gfapy.OrientedLine):
      raise gfapy.TypeError(
            "the list contains an object of class {}\n".format(type(elem))+
            "(accepted classes: gfapy.OrientedLine)")
    elem.validate()
    if not re.match(r"^[!-~]+$", elem.name):
      raise gfapy.FormatError(
        "the list contains an invalid GFA2 identifier {}\n".format(elem.name)+
        "(it contains spaces and/or non-printable characters)")
    if not elem.orient in ["+", "-"]:
      raise gfapy.FormatError(
        "{} is not a valid orientation".format(elem.orient))

def unsafe_encode(obj):
  if isinstance(obj, str):
    return obj
  elif isinstance(obj, list):
    retval = []
    for elem in obj:
      if not isinstance(elem, gfapy.OrientedLine):
        raise gfapy.TypeError(
              "the list contains an object of class {}\n".format(type(elem))+
              "(accepted classes: gfapy.OrientedLine)")
      retval.append(str(elem))
    return " ".join(retval)
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str, list)")

def encode(obj):
  validate_decoded(obj)
  return unsafe_encode(obj)
