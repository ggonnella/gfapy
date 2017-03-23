import gfapy
import re

class OrientedLine:
  """A line plus an orientation.

  The line can be an instance of `~gfapy.line.line.Line` or a string (line
  identifier). The orientation is a string, either ``'+'`` or ``'-'``.
  Methods not defined in this class are delegated to the line element.

  Parameters:
    value (str, list, OrientedLine) : a line identifier with a 1-letter
      orientation suffix + or -, or a list of two elements (identifier
      or line instance and orientation string), or an OrientedLine instance

  Returns:
    OrientedLine: if value is an OrientedLine, then
      it is returned; if it is a string, then an OrientedLine where line
      is a string (the string without the last char, which is the orientation);
      if it is a list, then an OrientedLine where line is the first element,
      orientation the second
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
    """The line.

    Returns:
      str or `~gfapy.line.line.Line`
    """
    return self.__line

  @property
  def orient(self):
    """The orientation.

    Returns:
      str : '+' or '-'
    """
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
    """The name of the line.

    Returns:
      str : if line is a string, then line; if it is a line instance,
            then line.name
    """
    if isinstance(self.__line, str):
      return self.__line
    else:
      return self.__line.name

  def validate(self):
    """Validate the content of the instance

    Raises:
      gfapy.error.ValueError: if the orientation is invalid
      gfapy.error.TypeError: if the line is not a string or a
        `gfapy.line.line.Line` instance
      gfapy.error.FormatError: if the line is a string which is not a valid
        line identifier, or it is a Line instance with an invalid name
    """
    self.__validate_line()
    self.__validate_orient()
    return None

  def inverted(self):
    """An oriented line with the same line element, but inverted orientation.

    Note:
      the inverted() method returns an OrientedLine with inverted orientation;
      the invert() method inverts the orientation in place (and returns None)
    """
    return OrientedLine(self.line, gfapy.invert(self.orient))

  def invert(self):
    """Invert the orientation of the OrientedLine instance.

    Note:
      the inverted() method returns an OrientedLine with inverted orientation;
      the invert() method inverts the orientation in place (and returns None)
    """
    self.orient = gfapy.invert(self.orient)

  def __str__(self):
    if self.name:
      return "{}{}".format(self.name, self.orient)
    else:
      return "({}){}".format(str(self.line), self.orient)

  def __repr__(self):
    return "gfapy.OrientedLine({},{})".format(repr(self.line),repr(self.orient))

  def __eq__(self, other):
    if isinstance(other, OrientedLine):
      pass
    elif isinstance(other, list):
      other = OrientedLine(other)
    elif isinstance(other, str):
      other = OrientedLine(other)
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
