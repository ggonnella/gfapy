from ..common.from_to import FromTo
from ..common.alignment_type import AlignmentType
from ..gfa1.to_gfa2 import ToGFA2 as GFA1_ToGFA2
from ..gfa1.alignment_type import AlignmentType as GFA1_AlignmentType
from ..gfa1.oriented_segments import OrientedSegments
from ..gfa1.references import References
from ..gfa1.other import Other
from ..containment.canonical import Canonical
from ..containment.pos import Pos
from ..containment.to_gfa2 import ToGFA2 as Containment_ToGFA2
from ..edge import Edge

class Containment(Containment_ToGFA2, Pos, Canonical, Other,
                  GFA1_AlignmentType, OrientedSegments, References,
                  GFA1_ToGFA2, AlignmentType, FromTo, Edge):
  """A containment line (C) of a GFA1 file

  Note:
    from_segment and to_segment are used instead of from/to
    as from is not a valid method name in Python. However, when not
    used as method name (e.g. as argument of get()), from and to can
    be used, as an alias has been defined.

  Note:
    The from segment is considered the container, the to segment the contained
    sequence. This is not indicated in the specification, but examples where
    done with this assumption in the GFA forum.
  """
  RECORD_TYPE = "C"
  POSFIELDS = ["from_segment", "from_orient", "to_segment",
               "to_orient", "pos", "overlap"]
  FIELD_ALIAS = {"container" : "from_segment",
                 "contained" : "to_segment",
                 "from" : "from_segment",
                 "to" : "to_segment",
                 "container_orient" : "from_orient",
                 "contained_orient" : "to_orient"}
  PREDEFINED_TAGS = ["MQ", "NM"]
  DATATYPE = {
     "from_segment" : "segment_name_gfa1",
     "from_orient" : "orientation",
     "to_segment" : "segment_name_gfa1",
     "to_orient" : "orientation",
     "pos" : "position_gfa1",
     "overlap" : "alignment_gfa1",
     "MQ" : "i",
     "NM" : "i",
  }
  REFERENCE_FIELDS = ["from_segment", "to_segment"]

Containment._apply_definitions()
