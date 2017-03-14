from .references import References
from ..line import Line

class Fragment(References, Line):
  """
  A fragment line of a GFA2 file
  """
  RECORD_TYPE = "F"
  POSFIELDS = ["sid", "external", "s_beg", "s_end", "f_beg", "f_end",
               "alignment"]
  STORAGE_KEY = "external"
  DATATYPE = {
    "sid" : "identifier_gfa2",
    "external" : "oriented_identifier_gfa2",
    "s_beg" : "position_gfa2",
    "s_end" : "position_gfa2",
    "f_beg" : "position_gfa2",
    "f_end" : "position_gfa2",
    "alignment" : "alignment_gfa2"
  }
  REFERENCE_FIELDS = ["sid"]

Fragment._apply_definitions()
