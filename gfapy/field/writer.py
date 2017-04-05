"""
Encoding of python objects to GFA string representation
"""
import gfapy

class Writer:

  @staticmethod
  def _to_gfa_field(obj, datatype = None, safe = True, fieldname = None,
                   line = None):
    """Encode an object into its GFA string representation.

    The python object can be either an encoded GFA field (in which case it
    is already a string, thus it is only at most, depending on the other
    parameters, validated), or an object of a class compatible
    with the specified datatype, if a datatype is specified (see **datatype**),
    e.g. Integer # for i fields.

    Parameters
    ----------
    obj : object
      the python object to encode
    datatype : str
      datatype to use (one of `~gfapy.field.field.Field.FIELD_DATATYPE`);
      If none is specified, the datatype is used, which is returned by the
      `gfapy.field.Field._get_default_gfa_tag_datatype` method.
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
      if an unknown datatype is specified, or the object type is not
      compatible with the datatype
    gfapy.ValueError
      if the object value is invalid for the datatype
    gfapy.FormatError
      if the object syntax is invalid for the
      datatype (eg for invalid encoded strings, if **safe** is set)
    """
    if not datatype:
      datatype = gfapy.Field._get_default_gfa_tag_datatype(obj)
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

  @staticmethod
  def _to_gfa_tag(obj, fieldname, datatype = None, line = None):
    """Representation of the data as a GFA tag.

    The representation is ``xx:d:content``, where ``xx`` is
    the tag name and ``d`` is the datatype.

    Parameters:
      obj (object): the python object to encode
      fieldname (string): the tag name
      datatype (string): (one of gfapy.Field.TAG_DATATYPE)
        the datatype; if not specified, the value returned by
        :func:``~gfapy.field.Field._get_default_gfa_tag_datatype``
        is used.
      line (string): the line content, for error messages
    """
    if not datatype:
      datatype = gfapy.Field._get_default_gfa_tag_datatype(obj)
    return "{}:{}:{}".format(fieldname, datatype,
            Writer._to_gfa_field(obj, datatype = datatype,
              fieldname = fieldname, line = line))
