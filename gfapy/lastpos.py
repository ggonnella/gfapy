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

  @staticmethod
  def get_value(obj):
    if isinstance(obj, LastPos):
      return obj.value
    else:
      return obj
  
  @staticmethod
  def get_is_last(obj):
    return isinstance(obj, LastPos)
  
  @staticmethod
  def get_is_first(obj):
    if isinstance(obj, LastPos):
      return False
    else:
      return obj == 0

  def __str__(self):
    return "{}$".format(self.value)

  def to_int(self):
    return self.value

  def is_first(self):
    return self.value == 0

  def is_last(self):
    return True

  def __eq__(self, other):
    if isinstance(other, Position):
      other = other.value
    return __eq__(self, other)

  def __sub__(self,other):
    if int(other) == 0:
      return copy.copy(self)
    else:
      return self.value - int(other)
