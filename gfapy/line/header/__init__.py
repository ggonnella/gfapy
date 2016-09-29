from .connection import Connection
from .multiline import Multiline
from .version_conversion import VersionConversion
from ..line import Line

class Header(VersionConversion, Multiline, Connection, Line):
  """
  A header line of a GFA file.

  For examples on how to set the header data, see {GFA.Headers}.

  See Also
  --------
  gfapy.Line
  """

  RECORD_TYPE = "H"
  POSFIELDS = []
  PREDEFINED_TAGS = ["VN"]
  FIELD_ALIAS = {}
  DATATYPE = {
    "VN" : "Z"
  }
  REFERENCE_FIELDS = []
  REFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = []
  OTHER_REFERENCES = []

Header._Line__define_field_methods()
