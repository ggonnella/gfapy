import gfapy
from .alignment import Alignment

class Trace(list):
  """
  List of trace points.

  A trace is a list of integers, each giving the number of characters
  in the second segment to align to the next TS characters in the first
  segment.

  TS is either the default spacing given in the header line TS tag,
  or the the spacing given in the TS tag on the line of the edge.

  Note: a complement operation such as for CIGARs cannot be defined
  for a trace, without computing the alignment.
  """

  def validate(self, ts = None):
    """
    Validate the numeric array

    Parameters
    ----------
    ts : int, optional
      Trace Spacing.
      If an integer is specified, it will be checked that all values
      are < **ts**. If **ts** == **None** (default), this check is skipped.

    Raises
    ------
    gfapy.TypeError
      If the list contains non-integer values
    gfapy.ValueError
      If the list contains values < 0 or > **ts**
    """
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

  @staticmethod
  def from_string(string):
    try:
      return Trace([int(v) for v in string.split(",")])
    except:
      raise gfapy.FormatError("string does not encode"+
          " a valid trace alignment: {}".format(string))
