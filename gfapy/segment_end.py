import gfapy
import re

class SegmentEnd:
  """A segment plus an end type (L or R).

  The ``segment`` can be an instance of a segment subclass of
  `~gfapy.line.line.Line` or a string (line identifier). The ``end_type``
  symbol is a string, either ``'L'`` or ``'R'``. Methods not defined in this
  class are delegated to the segment element.

  Parameters:
    value (str, list, SegmentEnd) : a line identifier with a 1-letter
      end symbol L or R, or a list of two elements (identifier
      or line instance and end symbol), or an SegmentEnd instance

  Returns:
    SegmentEnd: if value is an SegmentEnd, then
      it is returned; if it is a string, then an SegmentEnd where line
      is a string (the string without the last char, which is the end symbol);
      if it is a list, then an SegmentEnd where line is the first element,
      end symbol the second
  """

  def __new__(cls, *args):
    if isinstance(args[0], SegmentEnd):
      return args[0]
    else:
      new_instance = object.__new__(cls)
      return new_instance

  def __init__(self, *args):
    if len(args) == 1:
      if isinstance(args[0], SegmentEnd):
        return
      elif isinstance(args[0], str):
        self.__segment = args[0][0:-1]
        self.__end_type = args[0][-1]
      elif isinstance(args[0], list):
        if len(args[0]) != 2:
          raise gfapy.ArgumentError("Cannot create a SegmentEnd "+
            " from a list of size {}".format(len(args[0])))
        self.__segment = args[0][0]
        self.__end_type = args[0][1]
      else:
        raise gfapy.ArgumentError("Cannot create an SegmentEnd "+
            " from an object of type {}".format(type(args[0])))
    elif len(args) == 2:
      self.__segment = args[0]
      self.__end_type = args[1]
    else:
      raise gfapy.ArgumentError("Wrong number of arguments for SegmentEnd()")

  def validate(self):
    """Validate the content of the instance

    Raises:
      gfapy.error.ValueError: if the orientation is invalid
      gfapy.error.TypeError: if the segment is not a string or
        an instance of a segment subclass of `gfapy.line.line.Line`
      gfapy.error.FormatError: if the segment is a string which is not a valid
        segment identifier, or it is a segment Line instance with an invalid
        name
    """
    self.__validate_segment()
    self.__validate_end_type()
    return None

  def __validate_end_type(self):
    if not self.__end_type in ["L", "R"]:
      raise gfapy.ValueError(
          "Invalid end type ({})".format(repr(self.__end_type)))

  def __validate_segment(self):
    if isinstance(self.segment, gfapy.line.Segment):
      string = self.segment.name
    elif isinstance(self.segment, str):
      string = self.segment
    else:
      raise gfapy.TypeError(
        "Invalid class ({}) for segment reference ({})"
        .format(self.segment.__class__, self.segment))
    if not re.match(r"^[!-~]+$", string):
      raise gfapy.FormatError(
      "{} is not a valid segment identifier\n".format(repr(string))+
      "(it contains spaces or non-printable characters)")

  @property
  def segment(self):
    """The segment.

    Returns:
      str or `gfapy.line.segment.gfa1.GFA1` or `gfapy.line.segment.gfa2.GFA2`
    """
    return self.__segment

  @segment.setter
  def segment(self, value):
    self.__segment=value

  @property
  def name(self):
    """The name of the segment.

    Returns:
      str : if segment is a string, then segment; if it is a segment instance,
            then segment.name
    """
    if isinstance(self.__segment, gfapy.Line):
      return self.__segment.name
    else:
      return str(self.__segment)

  @property
  def end_type(self):
    """The end type.

    Returns:
      str : 'L' or 'R'
    """
    return self.__end_type

  @end_type.setter
  def end_type(self, value):
    self.__end_type = value

  def inverted(self):
    return SegmentEnd(self.__segment, gfapy.invert(self.end_type))

  def __str__(self):
    return "{}{}".format(self.name, self.end_type)

  def __repr__(self):
    return "gfapy.SegmentEnd({},{})".format(repr(self.segment),
                                            repr(self.end_type))

  def __eq__(self, other):
    if isinstance(other, list):
      other = SegmentEnd(other)
    elif isinstance(other, str):
      other = SegmentEnd(other)
    elif not isinstance(other, gfapy.SegmentEnd):
      return False
    return (self.name == other.name) and (self.end_type == other.end_type)

  def __getattr__(self, name):
    return getattr(self.__segment, name)
