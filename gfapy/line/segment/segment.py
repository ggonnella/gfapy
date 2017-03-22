from ..line import Line
import gfapy
import re

class Segment(Line):
  """
  Parent class for classes representing segment lines
  """

  @staticmethod
  def _subclass(data):
    n_positionals = len(data)-1
    for i in range(len(data)-1, 0, -1):
      if not re.search(r"^..:.:.*$", data[i]):
        break
      n_positionals = i-1
    if n_positionals == 2:
      return gfapy.line.segment.GFA1
    elif n_positionals == 3:
      return gfapy.line.segment.GFA2
    else:
      raise gfapy.FormatError("Wrong number of positional fields for "
          "segment line; GFA1=2, GFA2=3, found={}\n".format(n_positionals))
