import gfapy
import gfapy.line
from .collections import Collections
from .headers import Headers
from .collections import Collections
from .creators import Creators
from .destructors import Destructors
from .finders import Finders

class Lines(Collections, Creators, Destructors, Finders, Headers):

  #GFA1Specific = [
  #                 gfapy.Line.Edge.Link,
  #                 gfapy.Line.Edge.Containment,
  #                 gfapy.Line.Group.Path,
  #                 gfapy.Line.Segment.GFA1
  #               ]

  #GFA2Specific = [
  #                 gfapy.Line.CustomRecord,
  #                 gfapy.Line.Fragment,
  #                 gfapy.Line.Gap,
  #                 gfapy.Line.Edge.GFA2,
  #                 gfapy.Line.Segment.GFA2,
  #                 gfapy.Line.Group.Unordered,
  #                 gfapy.Line.Group.Ordered,
  #                 gfapy.Line.Unknown
  #               ]

  def __api_private_check_gfa_line(self, gfa_line, callermeth):
    if not isinstance(gfa_line, gfapy.Line):
      raise gfapy.TypeError("Note: {} is API private, ".format(callermeth)+
          "do not call it directly\n"+
          "Error: line class is {} and not gfapy.Line")
    elif not gfa_line.gfa is self:
      raise gfapy.RuntimeError("Note: {} is API private, ".format(callermeth)+
          "do not call it directly\n"+
          "Error: line.gfa is not the expected instance of gfapy.Line")
