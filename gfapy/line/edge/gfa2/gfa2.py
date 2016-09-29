from ..common.from_to import FromTo
from ..common.alignment_type import AlignmentType
from ..gfa2.to_gfa1 import ToGFA1
from ..gfa2.alignment_type import AlignmentType as GFA2_AlignmentType
from ..gfa2.references import References
from ..gfa2.other import Other
from .. import Edge

class GFA2(Other, References, GFA2_AlignmentType, ToGFA1, AlignmentType, FromTo, Edge):
  """An edge line of a GFA2 file"""

  RECORD_TYPE = "E"
  POSFIELDS = ["eid", "sid1", "sid2", "beg1", "end1", "beg2", "end2", "alignment"]
  PREDEFINED_TAGS = []
  DATATYPE = {
    "eid" : "optional_identifier_gfa2",
    "sid1" : "oriented_identifier_gfa2",
    "sid2" : "oriented_identifier_gfa2",
    "beg1" : "position_gfa2",
    "end1" : "position_gfa2",
    "beg2" : "position_gfa2",
    "end2" : "position_gfa2",
    "alignment" : "alignment_gfa2",
  }
  FIELD_ALIAS = { "name" : "eid" }
  REFERENCE_FIELDS = ["sid1", "sid2"]
  REFERENCE_RELATED_FIELDS = ["beg1", "end1", "beg2", "end2"]
  DEPENDENT_LINES = ["paths", "sets"]
  OTHER_REFERENCES = []

  def _str__(self):
    return self.eid

GFA2._Line__define_field_methods()
