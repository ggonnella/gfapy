import gfapy
import gfapy.line
from .collections import Collections
from .headers import Headers
from .creators import Creators
from .destructors import Destructors
from .finders import Finders

class Lines(Collections, Creators, Destructors, Finders, Headers):

  GFA1Specific = [
                   gfapy.line.edge.Link,
                   gfapy.line.edge.Containment,
                   gfapy.line.group.Path,
                   gfapy.line.segment.GFA1
                 ]

  GFA2Specific = [
                   gfapy.line.CustomRecord,
                   gfapy.line.Fragment,
                   gfapy.line.Gap,
                   gfapy.line.edge.GFA2,
                   gfapy.line.segment.GFA2,
                   gfapy.line.group.Unordered,
                   gfapy.line.group.Ordered,
                   gfapy.line.Unknown
                 ]

  def _api_private_check_gfa_line(self, gfa_line, callermeth):
    if not isinstance(gfa_line, gfapy.Line):
      raise gfapy.TypeError("Note: {} is API private, ".format(callermeth)+
          "do not call it directly\n"+
          "Error: line class is {} and not gfapy.Line")
    elif not gfa_line._gfa is self:
      raise gfapy.RuntimeError("Note: {} is API private, ".format(callermeth)+
          "do not call it directly\n"+
          "Error: line.gfa is not the expected instance of gfapy.Gfa\n"+
          repr(gfa_line.gfa)+" != "+repr(self))
