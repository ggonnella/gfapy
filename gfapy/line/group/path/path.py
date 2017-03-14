from .topology import Topology
from .references import References
from .validation import Validation
from .captured_path import CapturedPath
from .to_gfa2 import ToGFA2
from ..group import Group

class Path(Topology, References, Validation, CapturedPath, ToGFA2, Group):
  """A path line of a GFA1 file"""
  RECORD_TYPE = "P"
  POSFIELDS = ["path_name", "segment_names", "overlaps"]
  FIELD_ALIAS = { "name" : "path_name" }
  DATATYPE = {
    "path_name" : "path_name_gfa1",
    "segment_names" : "oriented_identifier_list_gfa1",
    "overlaps" : "alignment_list_gfa1",
  }
  NAME_FIELD = "path_name"
  REFERENCE_FIELDS = ["segment_names", "overlaps"]
  OTHER_REFERENCES = ["links"]

Path._apply_definitions()
