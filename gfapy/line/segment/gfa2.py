from .gfa2_to_gfa1 import GFA2ToGFA1
from .coverage import Coverage
from .references import References
from .writer_wo_sequence import WriterWoSequence
from . import Segment

class GFA2(WriterWoSequence, References, Coverage, GFA2ToGFA1, Segment):
  """A segment line of a GFA file"""

  VERSION = "gfa2"
  RECORD_TYPE = "S"
  POSFIELDS = ["sid", "slen", "sequence"]
  PREDEFINED_TAGS = ["RC", "FC", "KC", "SH", "UR"]
  DATATYPE = {
    "sid" : "identifier_gfa2",
    "slen" : "i",
    "sequence" : "sequence_gfa2",
    "RC" : "i",
    "FC" : "i",
    "KC" : "i",
    "SH" : "H",
    "UR" : "Z",
  }
  NAME_FIELD = "sid"
  FIELD_ALIAS = { "name" : "sid", "length" : "slen", "LN" : "slen" }
  DEPENDENT_LINES = ["dovetails_L", "dovetails_R", "gaps_L", "gaps_R",
                     "edges_to_contained", "edges_to_containers",
                     "fragments", "internals", "paths", "sets"]

GFA2._apply_definitions()
