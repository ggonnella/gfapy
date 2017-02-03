import gfapy
import copy

class LastPos:

  def __init__(self, value):
    self.value = value

  def validate(self):
    if not isinstance(self.value, int):
      raise gfapy.TypeError
    elif self.value < 0:
      raise gfapy.ValueError

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
    if isinstance(other, Position):
      other = other.value
    return __eq__(self, other)

  def __sub__(self,other):
    if int(other) == 0:
      return copy.copy(self)
    else:
      return self.value - int(other)

def posvalue(obj):
  if isinstance(obj, LastPos):
    return obj.value
  else:
    return obj

def islastpos(obj):
  return isinstance(obj, LastPos)

def isfirstpos(obj):
  return posvalue(obj) == 0

