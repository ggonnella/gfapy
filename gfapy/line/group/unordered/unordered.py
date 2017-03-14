from ..gfa2.references import References
from ..gfa2.same_id import SameID
from ..unordered.references import References as UnorderedReferences
from ..unordered.induced_set import InducedSet
from ..group import Group

class Unordered(UnorderedReferences, InducedSet, References, SameID, Group):
  """An unordered group line of a GFA2 file"""
  RECORD_TYPE = "U"
  POSFIELDS = ["pid", "items"]
  FIELD_ALIAS = {"name" : "pid"}
  DATATYPE = {
    "pid" : "optional_identifier_gfa2",
    "items" : "identifier_list_gfa2",
  }
  NAME_FIELD = "pid"
  REFERENCE_FIELDS = ["items"]
  DEPENDENT_LINES = ["sets"]

Unordered._apply_definitions()
