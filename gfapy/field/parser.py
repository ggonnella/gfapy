"""
Decoding of the GFA string representations into python objects
"""
import gfapy
import re

class Parser:

  @staticmethod
  def _parse_gfa_field(string, datatype, safe = True, fieldname = None,
                      line = None):
    """
    Parse a GFA string representation and decodes it into a python object

    Parameters
    ----------
    string : str
      the GFA string to parse
    datatype : one of gfapy.Field.FIELD_DATATYPE
      the datatype to use
    safe : bool, optional
      *(defaults to: ***True***)* if **True** the safe
      version of the decode function for the datatype is used, which
      validates the content of the string; if **False**, the string is
      assumed to be valid and decoded into a value accordingly, which may
      result in invalid values (but may be faster than the safe decoding)
    fieldname : str, optional
      fieldname for error messages
    line : gfapy.Line, optional
      line content for error messages

    Raises
    ------
    gfapy.TypeError
      if the specified datatype is unknown
    gfapy.FormatError
      if the string syntax is not valid
    gfapy.ValueError
      if the decoded value is not valid
    """
    mod = gfapy.Field.FIELD_MODULE.get(datatype)
    if mod is None:
      linemsg = ""
      try:
        if line is not None and not line.__error__:
          line.__error__ = True # avoids infinite recursion
          linemsg = ["Line content:"]
          linemsg.append(str(line))
          linemsg.append("\n")
      except:
        pass
      fieldnamemsg = "Field: {}\n".format(fieldname) if fieldname else ""
      contentmsg = "Content: {}\n".format(string)
      raise gfapy.TypeError(
        linemsg +
        fieldnamemsg +
        contentmsg +
        "Datatype unknown: {}".format(repr(datatype)))
    try:
      if safe or not getattr(mod, "unsafe_decode"):
        return mod.decode(string)
      else:
        return mod.unsafe_decode(string)
    except Exception as err:
      linemsg = ""
      try:
        if line is not None and not line.__error__:
          line.__error__ = True # avoids infinite recursion
          linemsg = ["Line content:"]
          linemsg.append(str(line))
          linemsg.append("\n")
      except:
        pass
      fieldnamemsg = "Field: {}\n".format(fieldname) if fieldname else ""
      contentmsg = "Content: {}\n".format(string)
      datatypemsg = "Datatype: {}\n".format(datatype)
      errmsg = err.message if hasattr(err, "message") else str(err)
      raise err.__class__(
            linemsg +
            fieldnamemsg +
            datatypemsg +
            contentmsg +
            errmsg) from err

  @staticmethod
  def _parse_gfa_tag(tag):
    """
    Parses a GFA tag in the form **xx:d:content** into its components.
    The **content** is not decoded (see :func:`_parse_gfa_field`).

    Parameters
    ----------
    tag : str
      the GFA tag to parse

    Raises
    ------
    gfapy.FormatError
      if the string does not represent a valid GFA tag

    Returns
    -------
    list of (str, gfapy.Field.FIELD_DATATYPE)
      the parsed content of the field
    """
    match = re.match(r"^([A-Za-z][A-Za-z0-9]):([AifZJHB]):(.+)$", tag)
    if match:
      return [match.group(1), match.group(2), match.group(3)]
    else:
      raise gfapy.FormatError(
        "Expected GFA tag, found: {}".format(repr(tag)))
