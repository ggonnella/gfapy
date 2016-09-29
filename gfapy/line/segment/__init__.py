from ..line import Line

class Segment(Line):
  """
  Parent class for classes representing S lines
  gfapy.Line.Segment.GFA1 and
  gfapy.Line.Segment.GFA2
  """

from .gfa1 import GFA1
from .gfa2 import GFA2
from .factory import Factory
