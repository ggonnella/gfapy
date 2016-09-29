from .topology import Topology
from .references import References
from .validation import Validation
from .captured_path import CapturedPath
from ..group import Group

class Path(Topology, References, Validation, CapturedPath, Group):
  """A path line of a GFA1 file"""

  RECORD_TYPE = "P"
  POSFIELDS = ["path_name", "segment_names", "overlaps"]
  PREDEFINED_TAGS = []
  FIELD_ALIAS = { "name" : "path_name" }
  DATATYPE = {
    "path_name" : "path_name_gfa1",
    "segment_names" : "oriented_identifier_list_gfa1",
    "overlaps" : "alignment_list_gfa1",
  }
  REFERENCE_FIELDS = ["segment_names", "overlaps"]
  REFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = []
  OTHER_REFERENCES = ["links"]

  def __str__(self):
    return self.path_name

Path._Line__define_field_methods()
