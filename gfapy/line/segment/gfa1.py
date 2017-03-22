from .gfa1_to_gfa2 import GFA1ToGFA2
from .length_gfa1 import LengthGFA1
from .coverage import Coverage
from .references import References
from .writer_wo_sequence import WriterWoSequence
from . import Segment

class GFA1(WriterWoSequence, References, Coverage,
           LengthGFA1, GFA1ToGFA2, Segment):
  """
  A segment line of a GFA file
  """

  VERSION = "gfa1"
  RECORD_TYPE = "S"
  POSFIELDS = ["name", "sequence"]
  PREDEFINED_TAGS = ["LN", "RC", "FC", "KC", "SH", "UR"]
  DATATYPE = {
    "name" : "segment_name_gfa1",
    "sequence" : "sequence_gfa1",
    "LN" : "i",
    "RC" : "i",
    "FC" : "i",
    "KC" : "i",
    "SH" : "H",
    "UR" : "Z",
  }
  NAME_FIELD = "name"
  FIELD_ALIAS = { "sid" : "name" }
  DEPENDENT_LINES = ["dovetails_L", "dovetails_R",
                     "edges_to_contained", "edges_to_containers", "paths"]
  gfa2_compatibility = ["gaps_L", "gaps_R", "fragments", "internals", "sets"]
  OTHER_REFERENCES = gfa2_compatibility

GFA1._apply_definitions()
