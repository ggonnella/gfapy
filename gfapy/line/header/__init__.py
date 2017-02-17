from .connection import Connection
from .multiline import Multiline
from .field_data import FieldData
from .version_conversion import VersionConversion
from ..line import Line

class Header(VersionConversion, Multiline, Connection, FieldData, Line):
  """
  A header line of a GFA file.

  For examples on how to set the header data, see {GFA.Headers}.

  See Also
  --------
  gfapy.Line
  """

  RECORD_TYPE = "H"
  POSFIELDS = []
  PREDEFINED_TAGS = ["VN", "TS"]
  FIELD_ALIAS = {}
  DATATYPE = {
    "VN" : "Z",
    "TS" : "i"
  }
  REFERENCE_FIELDS = []
  NAME_FIELD = None
  STORAGE_KEY = "merge"
  BACKREFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = []
  OTHER_REFERENCES = []

Header._apply_definitions()
