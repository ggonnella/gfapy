from ..gfa2.references import References as  GFA2_References
from ..gfa2.same_id import SameID
from .references import References as Ordered_References
from .captured_path import CapturedPath
from .to_gfa1 import ToGFA1
from .. import Group

class Ordered(Ordered_References, CapturedPath, GFA2_References, SameID, ToGFA1, Group):
  """
  An ordered group line of a GFA2 file
  """

  RECORD_TYPE = "O"
  POSFIELDS = ["pid", "items"]
  PREDEFINED_TAGS = []
  FIELD_ALIAS = { "name" : "pid" }
  DATATYPE = {
    "pid" : "optional_identifier_gfa2",
    "items" : "oriented_identifier_list_gfa2",
  }
  NAME_FIELD = "pid"
  STORAGE_KEY = "name"
  REFERENCE_FIELDS = ["items"]
  REFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = ["paths", "sets"]
  OTHER_REFERENCES = []

Ordered._apply_definitions()
