"""
Encoding of python objects to GFA string representation
"""
import gfapy

def to_gfa_field(obj, datatype = None, safe = True, fieldname = None,
                 line = None):
  """
  Encode a python object into a GFA field. The python object can be
  either an encoded GFA field (in which case, at most it is validated,
  see **safe**, but not encoded) or an object of a class compatible
  with the specified datatype, if a datatype is specified (see **datatype**),
  e.g. Integer # for i fields.

  Parameters
  ----------
  obj : object
    the python object to encode
  datatype : one of gfapy.Field.FIELD_DATATYPE, optional
  	datatype to use. If no
    datatype is specified, any class will do and the default datatype
    will be chosen (see gfapy.DefaultDatatype module).
  fieldname : str, optional
  	fieldname, for error messages
  line : gfapy.Line, optional
  	line, for error messages
  safe : bool, optional
  	*(defaults to: ***True***)* if **True**, the safe
    version of the encode function is used, which guarantees that the
    resulting data is valid; if **False**, the unsafe version is used,
    which, for some datatypes, skips validations in order to be faster
    than the safe version

  Raises
  ------
  gfapy.TypeError
  	if an unknown datatype is specified
  gfapy.ValueError
  	if the object value is invalid for the datatype
  gfapy.FormatError
  	if the object syntax is invalid for the
    datatype (eg for invalid encoded strings, if **safe** is set)
  gfapy.TypeError
  	if the type of the object and the datatype
    are not compatible
  """
  if not datatype:
    datatype = gfapy.Field.get_default_gfa_tag_datatype(obj)
  mod = gfapy.Field.FIELD_MODULE.get(datatype)
  if not mod:
    fieldnamemsg = "Field: {}\n".format(fieldname) if fieldname else ""
    contentmsg = "Content: {}\n".format(repr(obj))
    raise gfapy.TypeError(
      fieldnamemsg +
      contentmsg +
      "Datatype unknown: {}".format(repr(datatype)))
  try:
    if safe or not getattr(mod, "unsafe_encode"):
      return mod.encode(obj)
    else:
      return mod.unsafe_encode(obj)
  except Exception as err:
    fieldnamemsg = "Field: {}\n".format(fieldname) if fieldname else ""
    contentmsg = "Content: {}\n".format(repr(obj))
    datatypemsg = "Datatype: {}\n".format(datatype)
    raise err.__class__(
          fieldnamemsg +
          datatypemsg +
          contentmsg +
          str(err)) from err

def to_gfa_tag(obj, fieldname, datatype = None, line = None):
  """
  Representation of the data as a GFA tag **xx:d:content**, where **xx** is
  the tag name and **d** is the datatype.

  Parameters
  ----------
  obj : object
    the python object to encode
  fieldname : Symbol
    the tag name
  line : gfapy.Line, optional
    line, for error messages
  datatype : gfapy.Field.TAG_DATATYPE, optional
    (*defaults to: the value returned by 
      {gfapy.Field.get_default_gfa_tag_datatype}*)
  """
  if not datatype:
    datatype = gfapy.Field.get_default_gfa_tag_datatype(obj)
  return "{}:{}:{}".format(fieldname, datatype, 
          to_gfa_field(obj, datatype = datatype, fieldname = fieldname,
            line = line))
