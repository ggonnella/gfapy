import gfapy
from functools import total_ordering

@total_ordering
class LastPos:
  """The last position of a sequence.

  In GFA2 lines (e.g. edges and fragments), the last position of a sequence is
  suffixed by a ``$`` sign.

  This class is provided to represent this particular case of a position value.
  New instances are created passing an integer or the string representation
  to the constructor. If a string without ``$`` is passed to the constructor,
  an integer is returned instead (thus the constructor can be used to parse
  any GFA position field string).

  >>> from gfapy import LastPos
  >>> LastPos("2$")
  gfapy.LastPos(2)
  >>> LastPos(2)
  gfapy.LastPos(2)
  >>> LastPos("2")
  2

  Parameters:
    value (str, int) : a string representation of a position, or an integer
      representing the last position of a sequence
    valid (bool) : if True, the value is always considered valid, and no
      validation is performed (default: False)

  Returns:
    gfapy.LastPos, int : an int if the value is a string and has no dollar sign
      suffix; otherwise a LastPos instance

  Raises:
    see validate method (no exceptions raised if valid is set to True)

  """

  def __new__(cls, value, valid=False):
    if isinstance(value, str):
      return cls._from_string(value, valid=valid)
    else:
      new_instance = object.__new__(cls)
      new_instance.value = value
      if not valid:
        new_instance.validate()
      return new_instance

  def validate(self):
    """Checks that the value is a positive integer.

    Validation is performed by default on construction, unless the valid
    parameter of the constructor is set to True.

    Raises:
      gfapy.error.TypeError : if the value is not an integer
      gfapy.error.ValueError : if the value is not >= 0
    """

    if not isinstance(self.value, int):
      raise gfapy.TypeError("LastPos value shall be an integer,"+
          " {} found".format(type(self.value)))
    elif self.value < 0:
      raise gfapy.ValueError("LastPos value shall be >= 0,"+
          " {} found".format(self.value))

  def __str__(self):
    return "{}$".format(self.value)

  def __repr__(self):
    return "gfapy.LastPos({})".format(self.value)

  def __int__(self):
    return self.value

  def __eq__(self, other):
    if isinstance(other, int):
      return self.value == other
    elif not isinstance(other, LastPos):
      return NotImplemented
    else:
      return self.value == other.value

  def __lt__(self, other):
    if isinstance(other, int):
      return self.value.__lt__(other)
    elif not isinstance(other, LastPos):
      return NotImplemented
    else:
      return self.value.__lt__(other.value)

  def __sub__(self,other):
    o = int(other)
    if o == 0:
      return gfapy.LastPos(self.value)
    else:
      return self.value - o

  @classmethod
  def _from_string(cls, string, valid=False):
    if string[-1] == "$":
      return cls(int(string[:-1]), valid=valid)
    else:
      try:
        v = int(string)
      except:
        raise gfapy.FormatError(
            "LastPos value has a wrong format: {}".format(string))
      if not valid:
        if v < 0:
          raise gfapy.ValueError("LastPos value shall be >= 0,"+
              " {} found".format(v))
      return v

def posvalue(obj):
  """The integer representing a position.

  Parameters:
    obj (int, LastPos) : the position

  Returns:
    int : If obj is a LastPos, then its value.
          If it is an integer, then the integer itself.
  """
  if isinstance(obj, LastPos):
    return obj.value
  else:
    return obj

def islastpos(obj):
  """Checks if a position value is a last position.

  Parameters:
    obj (int, LastPos) : the position

  Returns:
    bool : If obj is a LastPos, then True.
           If it is an integer, then False.
  """
  return isinstance(obj, LastPos)

def isfirstpos(obj):
  """Checks if a position value is the first position (0).

  Note that the last position of an empty sequence
  is also its first position, therefore:

  >>> from gfapy.lastpos import isfirstpos
  >>> isfirstpos(gfapy.LastPos("0$"))
  True

  Parameters:
    obj (int, LastPos) : the position

  Returns:
    bool : If the value of the position is 0, then True.
  """
  return posvalue(obj) == 0

