import gfapy
import json
import re

def unsafe_decode(string):
  return json.loads(string)

def decode(string):
  validate_all_printable(string)
  return unsafe_decode(string)

def validate_encoded(string):
  # both regex and JSON parse are necessary,
  # because string can be invalid JSON and
  # JSON can contain forbidden chars (non-printable)
  validate_all_printable(string)
  try:
    json.loads(string)
  except Exception as err:
    raise Exception(
    "{} is not a valid JSON string\n".format(repr(string))+
    "json.loads raised a {} exception\n".format(err.__class__.__name__)+
    "error message: {}").format(str(err)) from err

def validate_decoded(obj):
  if isinstance(obj, gfapy.FieldArray):
    obj.validate()
  elif isinstance(obj, list) or isinstance(obj, dict):
    string = encode(obj)
    validate_all_printable(string)
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__) +
      "(accepted classes: list, dict, gfapy.FieldArray)")

def unsafe_encode(obj):
  return json.dumps(obj)

def encode(obj):
  if isinstance(obj, str):
    validate_encoded(obj)
    return obj
  elif isinstance(obj, list) or isinstance(obj, dict):
    string = json.dumps(obj)
    validate_all_printable(string)
    return string
  else:
    raise gfapy.TypeError(
      "the class {} is incompatible with the datatype\n"
      .format(obj.__class__.__name__) +
      "(accepted classes: list, dict, gfapy.FieldArray)")

def validate_all_printable(string):
  if not re.match("^[ !-~]+$", string):
    raise gfapy.FormatError(
      "{} is not a valid JSON field\n".format(repr(string))+
      "(it contains newlines, tabs and/or non-printable characters)")
