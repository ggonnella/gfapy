from .init import Init
from ..line import Line

class CustomRecord(Init, Line):
  """A custom line of a GFA2 file
  "Any line that does not begin with a recognized code can be ignored.
  This will allow users to have additional descriptor lines specific to their
  special processes."

  Parsing of custom lines is handled as follows:
  - divide content by tabs
  - from the back, fields are parsed using parse_gfa_tag;
  until an exception is thrown, they are all considered tags
  - from the first exception to the first field, they are all considered
  positional fields with name field0, field1, etc
  """

  RECORD_TYPE = None
  POSFIELDS = ["record_type"]
  DATATYPE = {
    "record_type" : "custom_record_type"
  }

CustomRecord._apply_definitions()
