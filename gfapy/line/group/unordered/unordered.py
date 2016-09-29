from ..gfa2.references import References
from ..gfa2.same_id import SameID
from ..unordered.references import References as UnorderedReferences
from ..unordered.induced_set import InducedSet
from ..group import Group

class Unordered(UnorderedReferences, InducedSet, References, SameID, Group):
  """An unordered group line of a GFA2 file"""

  RECORD_TYPE = "U"
  POSFIELDS = ["pid", "items"]
  PREDEFINED_TAGS = []
  FIELD_ALIAS = {"name" : "pid"}
  DATATYPE = {
    "pid" : "optional_identifier_gfa2",
    "items" : "identifier_list_gfa2",
  }
  REFERENCE_FIELDS = ["items"]
  REFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = ["sets"]
  OTHER_REFERENCES = []

  def __str__(self):
    return self.pid

Unordered._Line__define_field_methods()
