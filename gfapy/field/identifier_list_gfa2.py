import gfapy
import re

def unsafe_decode(string):
  return string.split(" ")

def decode(string):
  validate_encoded(string)
  return unsafe_decode(string)

def validate_encoded(string):
  if not re.match("^[ !-~]+$", string):
    raise gfapy.FormatError(
      "{} is not a valid list of GFA2 identifier\n".format(repr(string))+
      "(it contains non-printable characters)")

def validate_decoded(obj):
  if isinstance(obj, list):
    for elem in obj:
      if isinstance(elem, gfapy.Line):
        elem = str(elem.name)
      elif not isinstance(elem, str):
        raise gfapy.TypeError(
          "the list contains an obj of class {}\n"
          .format(elem.__class__.__name__)+
          "(accepted classes: str, gfapy.Line)")
      if not re.match("^[!-~]+$", elem):
        raise gfapy.FormatError(
        "the list contains an invalid GFA2 identifier ({})\n"
        .format(repr(elem))+
        "(it contains spaces and/or non-printable characters)")
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__) +
      "(accepted classes: list)")

def unsafe_encode(obj):
  if isinstance(obj, list):
    def func(elem):
      if isinstance(elem, str):
        return elem
      elif isinstance(elem, gfapy.Line):
        return str(elem.name)
      else:
        raise gfapy.TypeError(
          "the list contains an obj of class {}\n"
          .format(elem.__class__.__name__)+
          "(accepted classes: str, gfapy.Line)")
    return " ".join(map(func, obj))
  elif isinstance(obj, str):
    return obj
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: list, str)")

def encode(obj):
  validate_decoded(obj)
  return unsafe_encode(obj)
