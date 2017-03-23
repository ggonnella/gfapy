from .construction import Construction
from ..line import Line

class CustomRecord(Construction, Line):
  """Custom record of a GFA2 file.

  According to the specification, any line that does not begin with a
  recognized code can be ignored. This allows users to have additional
  descriptor lines specific to their special processes.

  Parsing of custom lines is handled as follows:
  - divide content by tabs
  - from the back, fields are parsed as GFA tags (XX:Y:...); until an exception
    is thrown, they are all considered tags
  - from the first exception back to the first field, they are all considered
    positional fields with name field1, field2, etc
  """

  RECORD_TYPE = None
  POSFIELDS = ["record_type"]
  DATATYPE = {
    "record_type" : "custom_record_type"
  }

CustomRecord._apply_definitions()
