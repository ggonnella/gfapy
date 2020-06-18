import gfapy

class Trace(list):
  """Trace alignment.

  A trace is a list of integers, each giving the number of characters
  in the second segment to align to the next ``TS`` characters in the first
  segment (where  ``TS``, the trace spacing, is either the default spacing
  given in the header line ``TS`` tag, or the the spacing given in the ``TS``
  tag on the line itself, where the trace alignment is used).

  Instances are usually created from their string representations, using the
  :class:`~gfapy.alignment.alignment.Alignment` factory class constructor.
  """

  def complement(self):
    """Computes the complement of the trace alignment.

    A complement operation (such as for CIGARs) cannot be defined
    for a trace, without computing the alignment. This is currently not
    available in gfapy.

    Returns:
      gfapy.AlignmentPlaceholder
    """
    return gfapy.AlignmentPlaceholder()

  def validate(self, ts = None, version = "gfa2"):
    """Validates the trace alignment

    Parameters:
      ts (int): Trace Spacing. If specified, it will be checked that all values
        are < **ts** (default: **None**, no check).
      version (str) : GFA version (must be 'gfa1' or 'gfa2')

    Raises:
      ~gfapy.error.TypeError: If the list contains non-integer values
      ~gfapy.error.ValueError: If the list contains values < 0 or > **ts**
      ~gfapy.error.VersionError: If the version is 'gfa1' or an invalid version
        string is provided
    """
    if version != "gfa2":
      if version == "gfa1":
        raise gfapy.VersionError("Traces are not compatible with GFA1")
      else:
        raise gfapy.VersionError("Version unknown: {}".format(repr(version)))
    for e in self:
      if not isinstance(e, int):
        raise gfapy.TypeError(
            ("Trace contains non-integer values ({0} found)\n" + "Content: {1}")
            .format(e, repr(self)))
      if e < 0:
        raise gfapy.ValueError(
            ("Trace contains value < 0 ({0} found)\n" + "Content: {1}")
            .format(e, repr(self)))
      if ts and e > ts:
        raise gfapy.ValueError(
            ("Trace contains value > TS ({0} found, TS = {2})\n" + "Content: {1}")
            .format(e, repr(self), ts))

  def __str__(self):
    if not self:
      return "*"
    else:
      return ",".join([str(v) for v in self])

  def __repr__(self):
    if not self:
      return 'gfapy.Trace([])'
    else:
      return "gfapy.Trace([{}])".format(str(self))

  @classmethod
  def _from_string(cls,string):
    try:
      return Trace([int(v) for v in string.split(",")])
    except:
      raise gfapy.FormatError("string does not encode"+
          " a valid trace alignment: {}".format(string))
