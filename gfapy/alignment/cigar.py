import re
import gfapy

class CIGAR(list):
  """
  List of gfapy.CIGAR.Operation.

  Represents the contents of a CIGAR string.
  """

  def complement(self):
    """
    Compute the CIGAR of the segments when these are switched.

    Examples
    --------
    >>> str(gfapy.CIGAR.from_string("2M1D3M").complement())
    "3M1I2M"


    Returns
    -------
    complement : gfapy.CIGAR
        (empty if CIGAR string is \*)
    """
    comp = list(reversed(self))
    for op in comp:
      if   op.code == "I": op.code = "D"
      elif op.code == "S": op.code = "D"
      elif op.code == "D": op.code = "I"
      elif op.code == "N": op.code = "I"
    return CIGAR(comp)

  @staticmethod
  def from_string(string, valid = False, version = "gfa1"):
    """
    Parse a CIGAR string into an array of CIGAR operations.

    Each operation is represented by a "gfapy.CIGAR.Operation",
    i.e. a tuple of operation length and operation symbol (one of MIDP).

    .. note:: The GFA1 specification does not forbid the
              other operation symbols (NSHX=); these are not allowed in GFA2
              and their use should be avoided.

    Parameters
    ----------
    string : str
    valid : bool, optional
      If **True** the string is guaranteed to be valid.
      (Defaults to **False**)
    version : str
      *gfa1* or *gfa2*

    Returns
    -------
    cigar: gfapy.CIGAR or gfapy.Placeholder

    Raises
    ------
    gfapy.FormatError
        If the string is not a valid CIGAR string.
    """
    if string == "*":
      return gfapy.Placeholder()
    cigar = CIGAR()
    if not valid:
      if version == "gfa1":
        if not re.match(r"^([0-9]+[MIDNSHPX=])+$", string):
          raise gfapy.FormatError()
      elif version == "gfa2":
        if not re.match(r"^([0-9]+[MIDP])+$", string):
          raise gfapy.FormatError()
    for m in re.finditer("([0-9]+)([MIDNSHPX=])", string):
      cigar.append(CIGAR.Operation(int(m.group(1)), m.group(2)))
    return cigar


  def __str__(self):
    """
    String representation of the CIGAR

    Returns
    -------
    string
      CIGAR string
    """
    if not self:
      return "*"
    else:
      return "".join([str(op) for op in self])

  def validate(self, version = "gfa1"):
    """
    Validate the instance.

    Parameters
    ----------
    version : str
      *gfa1* or *gfa2*

    Raises
    ------
    gfapy.ValueError
        If any component of the CIGAR is invalid.
    """
    if version != "gfa1" and version != "gfa2":
      raise gfapy.VersionError(
          "Version error: {}".format(repr(version)))
    for op in self:
      op.validate()

  def to_cigar(self, valid = None):
    """
    Parameters
    ----------
    valid
      Ignored, for compatibility only

    Returns
    -------
    self : gfapy.CIGAR
    """
    return self

  def to_alignment(self, allow_traces = True):
    """
    Parameters
    ----------
    allow_traces : bool
      Ignored, for compatibility only

    Returns
    -------
    self : gfapy.CIGAR
    """
    return self

  def length_on_reference(self):
    """
    Lenght of the aligned substring on the reference sequence
    (**from** sequence for GFA1 links/containments;
    **sid1** sequence for GFA2 edges)

    Returns
    -------
    int
      length of the aligned substring on the reference sequence
    """
    l = 0
    for op in self:
      if op.code in ["M", "=", "X", "D" , "N"]:
        l += op.length
    return l

  def length_on_query(self):
    """
    Lenght of the aligned substring on the query sequence
    (**to** sequence for GFA1 links/containments;
    **sid2** sequence for GFA2 edges)

    Returns
    -------
    int
      length of the aligned substring on the query sequence
    """
    l = 0
    for op in self:
      if op.code in ["M", "=", "X", "I", "S"]:
        l += op.length
    return l

  class Operation:
    """
    A operation in a CIGAR string.

    Attributes
    ----------
    length : int
        Length of the operation.
    code : one of gfapy.CIGAR.Operation.CODE
        Code of the operation.
    """

    CODE_GFA1_ONLY = ["S", "H", "N", "X", "="]
    CODE_GFA1_GFA2 = ["M", "I", "D", "P"]
    CODE = CODE_GFA1_ONLY + CODE_GFA1_GFA2
    """CIGAR operation codes"""

    def __init__(self, length, code):
      """
      Parameters
      ----------
      length : int
          Length of the operation.
      code : one of gfapy.CIGAR.Operation.CODE
          Code of the Operation.
      """
      self.length = length
      self.code = code

    def __str__(self):
      """
      The string representation of the operation.
      """
      return "{}{}".format(self.length, self.code)


    def __eq__(self, other):
      """
      Compare two operations.

      Returns
      -------
      equality : bool
      """
      return self.length == other.length and self.code == other.code

    def validate(self, version = "gfa1"):
      """
      Validate the operation.

      Parameters
      ----------
      version : str
        *gfa1* or *gfa2*

      Returns
      -------
      validity : bool

      Raises
      ------
      gfapy.ValueError
        If the code is invalid or the length is no positive integer
        larger than zero.
      """
      if version != "gfa1" and version != "gfa2":
        raise gfapy.VersionError(
            "Version error: {}".format(repr(version)))
      if(int(self.length) <= 0):
        raise ValueError()
      if version == "gfa2":
        if not self.code in Operation.CODE_GFA1_GFA2:
          raise ValueError()
      else:
        if not self.code in Operation.CODE:
          raise ValueError()

Operation = CIGAR.Operation
