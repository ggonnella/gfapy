import gfapy
import re

def unsafe_decode(string):
  elements = []
  current_direction = None
  current_name = ""
  for char in string:
    if char == '>' or char == '<':
      if current_direction is not None:
        elements.append(gfapy.WalkElement(current_direction, current_name))
      current_direction = char
      current_name = ""
    else:
      current_name += char
  return elements

def decode(string):
  validate_encoded(string)
  return unsafe_decode(string)

def validate_encoded(string):
  if not re.match(r"^([><][!-;=?-~])+$", string):
    raise gfapy.FormatError(
      "{} is not a valid walk description".format(repr(string)))

def validate_decoded(iterable):
  for elem in iterable:
    if not isinstance(elem, gfapy.WalkElement):
      raise gfapy.TypeError(
            "the list contains an object of class {}\n".format(type(elem))+
            "(accepted classes: gfapy.WalkElement)")
    elem.validate()
    if not elem.direction in [">", "<"]:
      raise gfapy.FormatError(
        "{} is not a valid direction".format(elem.direction))
    if not re.match(r"^[!-;=?-~]+$", elem.name):
      raise gfapy.FormatError(
        "the list contains an invalid GFA1.1 identifier {}\n".format(elem.name)+
        "(it contains spaces and/or non-printable characters)")

def unsafe_encode(obj):
  if isinstance(obj, str):
    return obj
  elif isinstance(obj, list):
    retval = []
    for elem in obj:
      if not isinstance(elem, gfapy.WalkElement):
        raise gfapy.TypeError(
              "the list contains an object of class {}\n".format(type(elem))+
              "(accepted classes: gfapy.WalkElement)")
      retval.append(str(elem))
    return "".join(retval)
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str, list)")

def encode(obj):
  validate_decoded(obj)
  return unsafe_encode(obj)
