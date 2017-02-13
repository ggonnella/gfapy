import gfapy
import copy

class LastPos:

  def __init__(self, value):
    self.value = value

  def validate(self):
    if not isinstance(self.value, int):
      raise gfapy.TypeError("LastPos value shall be an integer,"+
          " {} found".format(type(self.value)))
    elif self.value < 0:
      raise gfapy.ValueError("LastPos value shall be >= 0,"+
          " {} found".format(self.value))

  @staticmethod
  def from_string(string):
    if string[-1] == "$":
      return LastPos(int(string[:-1]))
    else:
      return int(string)

  def __str__(self):
    return "{}$".format(self.value)

  def to_int(self):
    return self.value

  def __eq__(self, other):
    if not isinstance(other, LastPos):
      return False
    return self.value == other.value

  def __sub__(self,other):
    o = int(other)
    if o == 0:
      return copy.copy(self)
    else:
      return self.value - o

  def __int__(self):
    return self.value

def posvalue(obj):
  if isinstance(obj, LastPos):
    return obj.value
  else:
    return obj

def islastpos(obj):
  return isinstance(obj, LastPos)

def isfirstpos(obj):
  return posvalue(obj) == 0

