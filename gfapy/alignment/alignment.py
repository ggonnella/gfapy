import gfapy

class Alignment:
  """Factory for instances of classes which represent alignments in GFA fields.

  Args:
    initializer (string, list): the alignment field content
    version (str): GFA version, either ``'gfa1'`` or ``'gfa2'`` (default: ``'gfa2'``)
    valid (bool): if ``True``, validation is skipped, when possible (default: ``False``)

  Returns:
    :class:`~gfapy.alignment.cigar.CIGAR`,
    :class:`~gfapy.alignment.trace.Trace`,
    :class:`~gfapy.alignment.placeholder.AlignmentPlaceholder`

  Raises:
    ~gfapy.error.ArgumentError: If more the one positional parameter is used.
    ~gfapy.error.FormatError: If the ``initializer`` string/list is invalid.
    ~gfapy.error.VersionError: If ``version`` is invalid, or ``initializer`` is
        incompatible with the ``version``.

  Examples:
    >>> import gfapy
    >>> from gfapy.alignment import Alignment
    >>> Alignment("*")
    gfapy.AlignmentPlaceholder()
    >>> Alignment("12M2I2D")
    gfapy.CIGAR([gfapy.CIGAR.Operation(12,'M'), gfapy.CIGAR.Operation(2,'I'), gfapy.CIGAR.Operation(2,'D')])
    >>> Alignment("12,23,1")
    gfapy.Trace([12,23,1])
    >>> Alignment([])
    gfapy.AlignmentPlaceholder()
    >>> Alignment([gfapy.CIGAR.Operation(12,'M'), gfapy.CIGAR.Operation(2,'I'), gfapy.CIGAR.Operation(2,'D')])
    gfapy.CIGAR([gfapy.CIGAR.Operation(12,'M'), gfapy.CIGAR.Operation(2,'I'), gfapy.CIGAR.Operation(2,'D')])
    >>> Alignment([12,23,1])
    gfapy.Trace([12,23,1])
  """

  def __new__(cls, *args, **kargs):
    """Create an instance of an alignment field class."""
    if args[0] is None or \
        gfapy.is_placeholder(args[0]):
      return gfapy.AlignmentPlaceholder()
    if len(args) > 1:
      raise gfapy.ArgumentError("The Alignment() constructor requires "+
          "a single positional argument, {} found".format(len(args)))
    if isinstance(args[0], gfapy.CIGAR) or \
        isinstance(args[0], gfapy.Trace):
      return args[0]
    if isinstance(args[0], str):
      return Alignment._from_string(*args, **kargs)
    elif isinstance(args[0], list):
      return Alignment._from_list(*args, **kargs)
    else:
      raise gfapy.ArgumentError("Cannot create an alignment "+
          "from an instance of the class {}".format(type(args[0])))

  @classmethod
  def _from_string(cls, string, version = "gfa2", valid = False):
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
          return gfapy.AlignmentPlaceholder()
      else:
        if char.isdigit():
          continue
        elif char == ",":
          if version == "gfa2":
            t = gfapy.Trace._from_string(string)
            if not valid:
              t.validate()
            return t
          else:
            raise gfapy.FormatError(
                  "Trace alignments are not allowed in GFA1: {}"
                  .format(repr(string)))
        elif char in ["M","I","D","P"] or (char in ["=","X","S","H","N"]
            and version == "gfa1"):
          return gfapy.CIGAR._from_string(string, valid=valid, version=version)
      break
    raise gfapy.FormatError("Alignment field contains invalid data {}"
                            .format(repr(string)))


  @classmethod
  def _from_list(cls, array, version = "gfa2", valid = True):
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
      return gfapy.AlignmentPlaceholder()
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
