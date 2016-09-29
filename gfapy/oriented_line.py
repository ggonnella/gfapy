import gfapy
import re

class OrientedLine:
  """
  A line or line identifier plus an orientation.
  """

  def __init__(self, line, orient):
    self.__line = line
    self.__orient = str(orient)
    self.__editable = True

  @property
  def line(self):
    return self.__line

  @property
  def orient(self):
    return self.__orient

  @line.setter
  def line(self, line):
    if self.__editable:
      self.__line = line
    else:
      raise "gfapy.OrientedLine instance cannot be edited ({})".format(self)

  @orient.setter
  def orient(self, orient):
    if self.__editable:
      self.__orient = orient
    else:
      raise "gfapy.OrientedLine instance cannot be edited ({})".format(self)

  @property
  def name(self):
    """
    Returns
    -------
    str
      the line name
    """
    return str(self.__line)

  def validate(self):
    self.validate_line()
    self.validate_orient()
    return None

  def invert(self):
    """
    Returns
    -------
    gfapy.OrientedLine
      same line, inverted orientation
    """
    return OrientedLine(self.line, self.orient.invert())

  def __str__(self):
    """
    Returns
    -------
    str
      line name and orientation
    """
    return "{}{}".format(self.name, self.orient)

  def __eq__(self, other):
    """
    Compare the segment names and orientations of two instances

    Parameters
    ----------
    other : gfapy.OrientedLine or Array
      the other instance

    Returns
    -------
    bool
    """
    if isinstance(other, OrientedLine):
      pass
    elif isinstance(other, list):
      other = OrientedLine.from_list(other)
    elif isinstance(other, str):
      other = OrientedLine.from_string(other)
    else:
      return False
    return (self.name == other.name) and (self.orient == other.orient)

  def block(self):
    self.editable = False

  def unblock(self):
    self.editable = True

  def to_oriented_line(self):
    return self

  def validate_orient(self):
    if not self.orient in ["+", "-"]:
      raise gfapy.ValueError("Invalid orientation ({})".format(self.orient))

  def validate_line(self):
    if isinstance(self.line, gfapy.Line):
      string = self.line.name
    elif isinstance(self.line, str):
      string = self.line
    else:
      raise gfapy.TypeError(
        "Invalid class ({}) for line reference ({})"
        .format(self.line.__class__, self.line))
    if not re.match(r"^[!-~]+$", string):
      raise gfapy.FormatError(
      "{} is not a valid GFA2 identifier\n".format(repr(string))+
      "(it contains spaces or non-printable characters)")

  @staticmethod
  def from_string(string):
    return OrientedLine(string[0:-1], string[-1])

  @staticmethod
  def from_list(lst):
    return OrientedLine(str(lst[0]), str(lst[1]))
