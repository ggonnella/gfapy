import gfapy
from .references import References
from ..line import Line

class Gap(References, Line):
  """
  A gap line of a GFA2 file
  """

  RECORD_TYPE = "G"
  POSFIELDS = ["gid", "sid1", "sid2", "disp", "var"]
  FIELD_ALIAS = { "name" : "gid" }
  PREDEFINED_TAGS = []
  NAME_FIELD = "gid"
  STORAGE_KEY = "name"
  DATATYPE = {
    "gid" : "optional_identifier_gfa2",
    "sid1" : "oriented_identifier_gfa2",
    "sid2" : "oriented_identifier_gfa2",
    "disp" : "i",
    "var" : "optional_integer"
  }
  REFERENCE_FIELDS = ["sid1", "sid2"]
  REFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = []
  OTHER_REFERENCES = []

Gap._Line__define_field_methods()
