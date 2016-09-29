import gfapy
import re

def unsafe_decode(string):
  return gfapy.OrientedLine(string[:-1], string[-1])

def decode(string):
  obj = unsafe_decode(string)
  validate_decoded(obj)
  return obj

def validate_encoded(string):
  if not re.match("^[!-~]+[+-]$", string):
    raise gfapy.FormatError(
      "{} is not a valid oriented GFA2 identifier\n".format(repr(string))+
      "(it contains spaces or non-printable characters, or a wrong orientation)")

def validate_decoded(obj):
  if isinstance(obj, gfapy.OrientedLine):
    if not re.match("^[!-~]+$", obj.name):
      raise gfapy.FormatError(
          "{} is not a valid oriented GFA2 identifier\n".format(repr(obj.name)))
    if obj.orient != "+" and obj.orient != "-":
      raise gfapy.FormatError(
          "{} is not a valid orientation\n".format(repr(obj.orient)))
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: gfapy.OrientedLine)")

def unsafe_encode(obj):
  if isinstance(obj, str):
    return obj
  if isinstance(obj, gfapy.OrientedLine):
    return str(obj)
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__)+
      "(accepted classes: str, gfapy.OrientedLine)")

def encode(obj):
  string = unsafe_encode(obj)
  validate_encoded(string)
  return string
