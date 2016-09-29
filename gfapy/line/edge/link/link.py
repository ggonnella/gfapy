from ..common.alignment_type import AlignmentType
from ..common.from_to import FromTo
from ..gfa1.to_gfa2 import ToGFA2
from ..gfa1.references import References as GFA1_References
from ..gfa1.oriented_segments import OrientedSegments
from ..gfa1.alignment_type import AlignmentType as GFA1_AlignmentType
from ..gfa1.other import Other
from ..link.canonical import Canonical
from ..link.complement import Complement
from ..link.equivalence import Equivalence
from ..link.references import References as Link_References
from ..link.to_gfa2 import ToGFA2 as Link_ToGFA2
from .. import Edge

class Link(Link_ToGFA2, Link_References, Equivalence, Complement, Canonical, Other, GFA1_AlignmentType, OrientedSegments, GFA1_References, ToGFA2, AlignmentType, FromTo, Edge):
  """A link connects two segments, or a segment to itself."""
  RECORD_TYPE = "L"
  POSFIELDS = ["from", "from_orient", "to", "to_orient", "overlap"]
  PREDEFINED_TAGS = ["MQ", "NM", "RC", "FC", "KC"]
  FIELD_ALIAS = {"frm" : "from"}
  DATATYPE = {
    "from" : "segment_name_gfa1",
    "from_orient" : "orientation",
    "to" : "segment_name_gfa1",
    "to_orient" : "orientation",
    "overlap" : "alignment_gfa1",
    "MQ" : "i",
    "NM" : "i",
    "RC" : "i",
    "FC" : "i",
    "KC" : "i",
  }
  REFERENCE_FIELDS = ["from", "to"]
  REFERENCE_RELATED_FIELDS = ["to_orient", "from_orient", "overlap"]
  DEPENDENT_LINES = ["paths"]
  OTHER_REFERENCES = []


Link._Line__define_field_methods()
