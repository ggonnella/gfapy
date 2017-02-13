from ..line import Line

class Segment(Line):
  """
  Parent class for classes representing S lines
  gfapy.line.segment.GFA1 and
  gfapy.line.segment.GFA2
  """

from .gfa1 import GFA1
from .gfa2 import GFA2
from .factory import Factory
