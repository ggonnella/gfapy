import re
import gfapy

class CIGAR(list):
  """
  Representation of the contents of a CIGAR string.

  Each operation is represented by a
  :class:`CIGAR.Operation <gfapy.alignment.cigar.CIGAR.Operation>`,
  which specifies an operation length and operation symbol.

  Instances are usually created from their string representations, using the
  :class:`~gfapy.alignment.alignment.Alignment` factory class constructor.

  Warning:
    Although the GFA1 specification does not forbid the
    operation symbols NSHX=, these are not allowed in GFA2
    and thus their use in GFA1 is discouraged.
  """

  def complement(self):
    """The CIGAR when switching the role of the two aligned segments.

    Example:
      >>> import gfapy
      >>> str(gfapy.Alignment("2M1D3M").complement())
      '3M1I2M'

    Returns:
      CIGAR: the complement CIGAR
    """
    comp = list(reversed(self))
    for op in comp:
      if   op.code == "I": op.code = "D"
      elif op.code == "S": op.code = "D"
      elif op.code == "D": op.code = "I"
      elif op.code == "N": op.code = "I"
    return CIGAR(comp)

  def validate(self, version = "gfa1"):
    """Validates the instance.

    Parameters:
      version (str): 'gfa1' or 'gfa2'

    Raises:
      ~gfapy.error.VersionError: If a wrong **version** is specified.
      ~gfapy.error.TypeError: If a component of the list is not a
          CIGAR Operation; If the CIGAR operation length is not an integer or
          a string representing an integer.
      ~gfapy.error.ValueError: If the length of an operation is < 0; If an
          operation code is invalid in general or for the specified GFA version.
    """
    if version != "gfa1" and version != "gfa2":
      raise gfapy.VersionError(
          "Version error: {}".format(repr(version)))
    for op in self:
      if not isinstance(op, gfapy.CIGAR.Operation):
        raise gfapy.TypeError(
            "Element is not a CIGAR operation: {}\n".format(op)+
            "CIGAR instance is invalid: {}".format(self))
      op.validate(version = version)

  def length_on_reference(self):
    """Length of the aligned substring on the reference sequence
    (**from** sequence for GFA1 links/containments;
    **sid1** sequence for GFA2 edges)

    Returns:
      int
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

    Returns:
      int
    """
    l = 0
    for op in self:
      if op.code in ["M", "=", "X", "I", "S"]:
        l += op.length
    return l

  @classmethod
  def _from_string(cls, string, valid = False, version = "gfa1"):
    """Create a CIGAR instance from its string representation.

    Parameters:
      string (str)
      valid (bool): If **True** the string is guaranteed to be valid.
        (Defaults to **False**)
      version (str): 'gfa1' or 'gfa2'

    Returns:
      ~gfapy.alignment.cigar.CIGAR or
      ~gfapy.alignment.placeholder.AlignmentPlaceholder

    Raises:
      ~gfapy.error.FormatError: If the string is not a valid CIGAR string.
    """
    if string == "*":
      return gfapy.AlignmentPlaceholder()
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
    if not self:
      return "*"
    else:
      return "".join([str(op) for op in self])

  def __repr__(self):
    return "gfapy.CIGAR([{}])".format(", ".join([repr(op) for op in self]))

  class Operation:
    """An operation in a CIGAR string.

    Attributes:
      ~Operation.length (int): Operation length.
      code (str): Operation code, one of
          :attr:`~Operation.CODE`.
    """

    CODE_GFA1_ONLY = ["S", "H", "N", "X", "="]
    """Operations only valid in GFA1"""

    CODE_GFA1_GFA2 = ["M", "I", "D", "P"]
    """Operations valid in GFA1 and GFA2"""

    CODE = CODE_GFA1_ONLY + CODE_GFA1_GFA2
    """CIGAR operation codes"""

    def validate(self, version = "gfa1"):
      """Validates the CIGAR operation.

      Parameters:
        version (str): 'gfa1' or 'gfa2'

      Raises:
        ~gfapy.error.VersionError: If a wrong **version** is specified.
        ~gfapy.error.TypeError: If the CIGAR operation length is not an integer
            or a string representing an integer.
        ~gfapy.error.ValueError: If the length of an operation is < 0; If an
            operation code is invalid in general or for the specified GFA
            version.
      """
      if version != "gfa1" and version != "gfa2":
        raise gfapy.VersionError(
            "Version error: {}".format(repr(version)))
      if not isinstance(self.length, int) and not isinstance(self.length, str):
        raise gfapy.TypeError(
            "Type error: length of CIGAR is {}".format(self.length))
      if(int(self.length) < 0):
        raise gfapy.ValueError("Length of CIGAR is {}".format(self.length))
      if version == "gfa2":
        if not self.code in Operation.CODE_GFA1_GFA2:
          raise gfapy.ValueError()
      else:
        if not self.code in Operation.CODE:
          raise gfapy.ValueError()

    def __init__(self, length, code):
      self.length = length
      self.code = code

    def __len__(self):
      return self.length

    def __str__(self):
      return "{}{}".format(self.length, self.code)

    def __repr__(self):
      return "gfapy.CIGAR.Operation({},{})".format(self.length, repr(self.code))

    def __eq__(self, other):
      return self.length == other.length and self.code == other.code

Operation = CIGAR.Operation
