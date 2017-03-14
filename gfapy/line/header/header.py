from ..line import Line
from .connection import Connection
from .multiline import Multiline
from .field_data import FieldData
from .version_conversion import VersionConversion

class Header(VersionConversion, Multiline, Connection, FieldData, Line):
  """
  A header line of a GFA file.

  For examples on how to set the header data, see {GFA.Headers}.

  See Also
  --------
  gfapy.Line
  """

  RECORD_TYPE = "H"
  PREDEFINED_TAGS = ["VN", "TS"]
  DATATYPE = {
    "VN" : "Z",
    "TS" : "i"
  }
  STORAGE_KEY = "merge"

Header._apply_definitions()
