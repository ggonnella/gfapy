import gfapy
import copy
from functools import total_ordering

@total_ordering
class LastPos:

  def __new__(cls, value, valid=False):
    if isinstance(value, str):
      return cls.from_string(value, valid=valid)
    else:
      new_instance = object.__new__(cls)
      new_instance.value = value
      if not valid:
        new_instance.validate()
      return new_instance

  def validate(self):
    if not isinstance(self.value, int):
      raise gfapy.TypeError("LastPos value shall be an integer,"+
          " {} found".format(type(self.value)))
    elif self.value < 0:
      raise gfapy.ValueError("LastPos value shall be >= 0,"+
          " {} found".format(self.value))

  @classmethod
  def from_string(cls, string, valid=False):
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

def posvalue(obj):
  if isinstance(obj, LastPos):
    return obj.value
  else:
    return obj

def islastpos(obj):
  return isinstance(obj, LastPos)

def isfirstpos(obj):
  return posvalue(obj) == 0

