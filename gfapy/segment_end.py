import gfapy

class SegmentEnd(list):
  """
  A segment or segment name plus an end symbol (L or R)
  """

  def validate(self):
    """
    Check that the elements of the array are compatible with the definition.

    Raises
    ------
    gfapy.ValueError
      if size is not 2
    gfapy.ValueError
      if second element
      is not a valid info
    """
    if size != 2:
      raise gfapy.ValueError("Wrong n of elements, 2 expected ({})"
                             .format(repr(self)))
    if not self[1] in ["L", "R"]:
      raise gfapy.ValueError("Invalid end type ({})".format(repr(self[1])))

  @property
  def segment(self):
    """
    Returns
    -------
    gfapy.Symbol or gfapy.Line.SegmentGFA1 or gfapy.Line.SegmentGFA2
      the segment instance or name
    """
    return self[0]

  @segment.setter
  def segment(self, value):
    """
    Set the segment
    Parameters
    ----------
    value : gfapy.Symbol or gfapy.Line.SegmentGFA1 or gfapy.Line.SegmentGFA2
      the segment instance or name
    """
    self[0]=value

  @property
  def name(self):
    """
    Returns
    -------
    str
      the segment name
    """
    return (self[0].name if isinstance(self[0], gfapy.Line) else str(self[0]))

  @property
  def end_type(self):
    """
    Returns
    -------
    str
      the attribute
    """
    return self[1]

  @end_type.setter
  def end_type(self, value):
    """
    Set the attribute

    Parameters
    ----------
    value : Symbol
      the attribute
    """
    self[1]=(value)

  def invert(self):
    return SegmentEnd([ self[0], invert(self[1])])

  def __str__(self):
    """
    Returns
    -------
    str
      name of the segment and attribute
    """
    return "{}{}".format(name, self.attribute)

  def __eq__(self, other):
    """
    Compare the segment names and attributes of two instances

    Parameters
    ----------
    other : gfapy.SegmentInfo
      the other instance

    Returns
    -------
    bool
    """
    return str(self) == str(other.to_segment_info(self.__class__))
  
  @classmethod
  def from_list(cls, l):
    """
    Create and validate a SegmentInfo from an list

    Returns
    -------
    gfapy.SegmentInfo
    """
    if isinstance(l, cls):
      return l
    se = cls([ str(e) for e in l])
    se.validate()
    return se
