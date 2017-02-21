import gfapy
import re

class SegmentEnd:
  """
  A segment or segment name plus an end symbol (L or R)
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
        self.__segment = args[0][0]
        self.__end_type = args[0][1]
      else:
        raise gfapy.ArgumentError("Cannot create an SegmentEnd"+
            " instance from an object of type {}".format(type(args[0])))
    elif len(args) == 2:
      self.__segment = args[0]
      self.__end_type = args[1]
    else:
      raise gfapy.ArgumentError("Wrong number of arguments for SegmentEnd()")

  def validate(self):
    """
    Check that the elements of the array are compatible with the definition.

    Raises
    ------
    gfapy.ValueError
      if second element
      is not a valid info
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
    """
    Returns
    -------
    gfapy.Symbol or gfapy.line.segment.GFA1 or gfapy.line.segment.GFA2
      the segment instance or name
    """
    return self.__segment

  @segment.setter
  def segment(self, value):
    """
    Set the segment
    Parameters
    ----------
    value : gfapy.Symbol or gfapy.line.segment.GFA1 or gfapy.line.segment.GFA2
      the segment instance or name
    """
    self.__segment=value

  @property
  def name(self):
    """
    Returns
    -------
    str
      the segment name
    """
    if isinstance(self.__segment, gfapy.Line):
      return self.__segment.name
    else:
      return str(self.__segment)

  @property
  def end_type(self):
    """
    Returns
    -------
    str
      the attribute
    """
    return self.__end_type

  @end_type.setter
  def end_type(self, value):
    """
    Set the attribute

    Parameters
    ----------
    value : Symbol
      the attribute
    """
    self.__end_type = value

  def inverted(self):
    return SegmentEnd(self.__segment, gfapy.invert(self.end_type))

  def __str__(self):
    """
    Returns
    -------
    str
      name of the segment and attribute
    """
    return "{}{}".format(self.name, self.end_type)

  def __repr__(self):
    return "gfapy.SegmentEnd({},{})".format(repr(self.segment),repr(self.end_type))

  def __eq__(self, other):
    """
    Compare the segment names and attributes of two instances

    Parameters
    ----------
    other : gfapy.SegmentEnd
      the other instance

    Returns
    -------
    bool
    """
    if isinstance(other, list):
      other = SegmentEnd.from_list(other)
    elif isinstance(other, str):
      other = SegmentEnd.from_string(other)
    elif not isinstance(other, gfapy.SegmentEnd):
      return False
    return (self.name == other.name) and (self.end_type == other.end_type)

  def __getattr__(self, name):
    return getattr(self.__segment, name)

  @classmethod
  def from_string(cls, string):
    """
    Create and validate a SegmentEnd from an list

    Returns
    -------
    gfapy.SegmentEnd
    """
    return SegmentEnd(string[0:-1], string[-1])

  @classmethod
  def from_list(cls, lst, valid=True):
    """
    Create and validate a SegmentEnd from an list

    Returns
    -------
    gfapy.SegmentEnd
    """
    if len(lst) != 2:
      raise gfapy.ArgumentError("SegmentEnd.from_list requires a list of"+
          " two elements as argument, {} found".format(repr(lst)))
    se = SegmentEnd(lst[0], str(lst[1]))
    if not valid:
      se.validate()
    return se
