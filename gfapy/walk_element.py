import gfapy
import re

class WalkElement:
  """A line and a direction

  The line can be an instance of `~gfapy.line.line.Line` or a string (line
  identifier). The direction is a string, either ``'>'`` or ``'<'``.
  Methods not defined in this class are delegated to the line element.

  Parameters:
    value (str, list, WalkElement) : a line identifier preceded by a 1-letter
      direction prefix > or <, or a list of two elements (direction string
      and line identifier or line instance), or a WalkElement instance

  Returns:
    WalkElement: if value is a WalkElement, then
      it is returned; if it is a string, then a WalkElement where line
      is a string (the string without the first char, which is the direction);
      if it is a list, then an WalkElement where direction is the first element,
      the line is the second element.
  """

  def __new__(cls, *args):
    if isinstance(args[0], WalkElement):
      return args[0]
    else:
      new_instance = object.__new__(cls)
      return new_instance

  def __init__(self, *args):
    if len(args) == 1:
      elem = args[0]
      if isinstance(elem, WalkElement):
        return
      elif isinstance(elem, str):
        self.__direction = elem[0]
        self.__line = elem[1:]
      elif isinstance(elem, list):
        self.__direction = elem[0]
        self.__line = elem[1]
      else:
        raise gfapy.ArgumentError("Cannot create an WalkElement"+
            " instance from an object of type {}".format(type(elem)))
    elif len(args) == 2:
      self.__direction = args[0]
      self.__line = args[1]
    else:
      raise gfapy.ArgumentError("Wrong number of arguments for WalkElement()")
    self.__editable = True

  @property
  def line(self):
    """The line.

    Returns:
      str or `~gfapy.line.line.Line`
    """
    return self.__line

  @property
  def direction(self):
    """The direction.

    Returns:
      str : '+' or '-'
    """
    return self.__direction

  @line.setter
  def line(self, line):
    if self.__editable:
      self.__line = line
    else:
      raise gfapy.RuntimeError(
          "gfapy.WalkElement instance cannot be edited ({})".format(self))

  @direction.setter
  def direction(self, direction):
    if self.__editable:
      self.__direction = direction
    else:
      raise gfapy.RuntimeError(
          "gfapy.WalkElement instance cannot be edited ({})".format(self))

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
      gfapy.error.ValueError: if the direction is invalid
      gfapy.error.TypeError: if the line is not a string or a
        `gfapy.line.line.Line` instance
      gfapy.error.FormatError: if the line is a string which is not a valid
        line identifier, or it is a Line instance with an invalid name
    """
    self.__validate_line()
    self.__validate_direction()
    return None

  def inverted(self):
    """An directioned line with the same line element, but inverted direction.

    Note:
      the inverted() method returns an WalkElement with inverted direction;
      the invert() method inverts the direction in place (and returns None)
    """
    return WalkElement(gfapy.invert(self.direction), self.line)

  def invert(self):
    """Invert the direction of the WalkElement instance.

    Note:
      the inverted() method returns an WalkElement with inverted direction;
      the invert() method inverts the direction in place (and returns None)
    """
    self.direction = gfapy.invert(self.direction)

  def __str__(self):
    if self.name:
      return "{}{}".format(self.direction, self.name)
    else:
      return "{}({})".format(self.direction, str(self.line))

  def __repr__(self):
    return "gfapy.WalkElement({},{})".format(repr(self.direction),
                                             repr(self.line))

  def __eq__(self, other):
    if isinstance(other, WalkElement):
      pass
    elif isinstance(other, list):
      other = WalkElement(other)
    elif isinstance(other, str):
      other = WalkElement(other)
    else:
      return False
    return (self.name == other.name) and (self.direction == other.direction)

  # Delegate methods to the line
  def __getattr__(self, name):
    return getattr(self.__line, name)

  def _block(self):
    self.__editable = False

  def _unblock(self):
    self.__editable = True

  def __validate_direction(self):
    if not self.direction in [">", "<"]:
      raise gfapy.ValueError("Invalid direction ({})".format(self.direction))

  def __validate_line(self):
    if isinstance(self.line, gfapy.Line):
      string = self.line.name
    elif isinstance(self.line, str):
      string = self.line
    else:
      raise gfapy.TypeError(
        "Invalid class ({}) for line reference ({})"
        .format(self.line.__class__, self.line))
    if not re.match(r"^[!-;=?-~]+$", string):
      raise gfapy.FormatError(
      "{} is not a valid GFA identifier\n".format(repr(string))+
      "(it contains spaces or non-printable characters)")
