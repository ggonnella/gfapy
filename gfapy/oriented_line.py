import gfapy
import re

class OrientedLine:
  """
  A line or line identifier plus an orientation.
  """

  def __new__(cls, *args):
    if isinstance(args[0], OrientedLine):
      return args[0]
    else:
      new_instance = object.__new__(cls)
      return new_instance

  def __init__(self, *args):
    if len(args) == 1:
      if isinstance(args[0], OrientedLine):
        return
      elif isinstance(args[0], str):
        self.__line = args[0][0:-1]
        self.__orient = args[0][-1]
      elif isinstance(args[0], list):
        self.__line = args[0][0]
        self.__orient = args[0][1]
      else:
        raise gfapy.ArgumentError("Cannot create an OrientedLine"+
            " instance from an object of type {}".format(type(args[0])))
    elif len(args) == 2:
      self.__line = args[0]
      self.__orient = args[1]
    else:
      raise gfapy.ArgumentError("Wrong number of arguments for OrientedLine()")
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
      raise gfapy.RuntimeError(
          "gfapy.OrientedLine instance cannot be edited ({})".format(self))

  @orient.setter
  def orient(self, orient):
    if self.__editable:
      self.__orient = orient
    else:
      raise gfapy.RuntimeError(
          "gfapy.OrientedLine instance cannot be edited ({})".format(self))

  @property
  def name(self):
    """
    Returns
    -------
    str
      the line name
    """
    if isinstance(self.__line, str):
      return self.__line
    else:
      return self.__line.name

  def validate(self):
    """
    Validates the content of the instance
    """
    self.__validate_line()
    self.__validate_orient()
    return None

  def inverted(self):
    """
    Returns:
      an oriented line with the same line element, but inverted orientation.
    """
    return OrientedLine(self.line, gfapy.invert(self.orient))

  def invert(self):
    """
    Invert in place
    """
    self.orient = gfapy.invert(self.orient)

  def __str__(self):
    """
    Returns
    -------
    str
      line name and orientation
    """
    if self.name:
      return "{}{}".format(self.name, self.orient)
    else:
      return "({}){}".format(str(self.line), self.orient)

  def __repr__(self):
    return "gfapy.OrientedLine({},{})".format(repr(self.line),repr(self.orient))

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

  # Delegate methods to the line
  def __getattr__(self, name):
    return getattr(self.__line, name)

  def _block(self):
    self.__editable = False

  def _unblock(self):
    self.__editable = True

  def __validate_orient(self):
    if not self.orient in ["+", "-"]:
      raise gfapy.ValueError("Invalid orientation ({})".format(self.orient))

  def __validate_line(self):
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
      "{} is not a valid GFA identifier\n".format(repr(string))+
      "(it contains spaces or non-printable characters)")

  @staticmethod
  def from_string(string):
    return OrientedLine(string[0:-1], string[-1])

  @staticmethod
  def from_list(lst):
    return OrientedLine(lst[0], str(lst[1]))
