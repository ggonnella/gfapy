"""
Methods to parse and handle alignment field contents
"""
import gfapy

class Alignment:

  def __new__(cls, *args, **kargs):
    if args[0] is None or \
        gfapy.is_placeholder(args[0]):
      return gfapy.AlignmentPlaceholder()
    if isinstance(args[0], gfapy.CIGAR) or \
        isinstance(args[0], gfapy.Trace):
      return args[0]
    if isinstance(args[0], str):
      return Alignment.from_string(*args, **kargs)
    elif isinstance(args[0], list):
      return Alignment.from_list(*args, **kargs)
    else:
      raise gfapy.ArgumentError("Cannot create an alignment "+
          "from an instance of the class {}".format(type(args[0])))

  @staticmethod
  def from_string(string, version = "gfa2", valid = False):
    """
    Parses an alignment field

    Parameters
    ----------
    string : str
      The string to parse.
    version : str
      GFA version (gfa1 or gfa2)
      If *gfa1*, then CIGARs and Placeholders are supported.
      If *gfa2*, also Traces are supported.
      Defaults to *gfa2*.
    valid : bool
      If *True*, the string is guaranteed to be valid, and
      further checks are skipped.
      Defaults to *False*.

    Returns
    -------
    gfapy.CIGAR or gfapy.Trace or gfapy.AlignentPlaceholder

    Raises
    ------
    gfapy.FormatError
      If the content of the field cannot be parsed.
    gfapy.VersionError
      If a wrong value is provided for the version parameter.
    """
    if version != "gfa1" and version != "gfa2":
      raise gfapy.VersionError(
          "Version error: {}".format(repr(version)))
    first = True
    for char in string:
      if first:
        if char.isdigit():
          first = False
          continue
        elif char == "*" and len(string) == 1:
          return gfapy.Placeholder()
      else:
        if char.isdigit():
          continue
        elif char == ",":
          if version == "gfa2":
            t = gfapy.Trace.from_string(string)
            if not valid:
              t.validate()
            return t
          else:
            raise gfapy.FormatError(
                  "Trace alignments are not allowed in GFA1: {}"
                  .format(repr(string)))
        elif char in ["M","I","D","P"] or (char in ["=","X","S","H","N"] and version == "gfa1"):
          return gfapy.CIGAR.from_string(string, valid=valid, version=version)
      break
    raise gfapy.FormatError("Alignment field contains invalid data {}"
                            .format(repr(string)))


  @staticmethod
  def from_list(array, version = "gfa2", valid = True):
    """
    Converts an alignment array into a specific list type

    Parameters
    ----------
    array : list
      The alignment array.
    version : str
      GFA version (gfa1 or gfa2)
      If *gfa1*, then CIGARs and Placeholders are supported.
      If *gfa2*, also Traces are supported.
      Defaults to *gfa2*.
    valid : bool
      If *True*, the list is guaranteed to be valid, and
      further checks are skipped.
      Defaults to *False*.

    Returns
    -------
    gfapy.CIGAR or gfapy.Trace
    """
    if version != "gfa1" and version != "gfa2":
      raise gfapy.VersionError(
          "Version error: {}".format(repr(version)))
    if not array:
      return gfapy.Placeholder()
    elif isinstance(array[0], int):
      if version == "gfa2":
        return gfapy.Trace(array)
      else:
        raise gfapy.VersionError(
          "Trace alignments are not allowed in GFA1: {}".format(repr(array)))
    elif isinstance(array[0], gfapy.CIGAR.Operation):
      return gfapy.CIGAR(array)
    else:
      raise gfapy.FormatError(
        "Array does not represent a valid alignment field: {}"
        .format(repr(array)))
