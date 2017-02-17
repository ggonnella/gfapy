import gfapy
from ..line import Line
from .init import Init
from .tags import Tags
from .writer import Writer

class Comment(Writer, Tags, Init, Line):
  """
  A comment line of a GFA file

  The content of the comment line, excluding the initial **#** and eventual
  initial spacing characters, is included in the field **content**.

  The initial spacing characters can be read/changed using the **spacer**
  field. The default value is a single space.

  Tags are not supported by comment lines. If the line contains tags,
  these are nor parsed, but included in the **content** field.
  Trying to set or get tag values raises exceptions.
  """

  RECORD_TYPE = "#"
  POSFIELDS = ["content", "spacer"]
  PREDEFINED_TAGS = []
  DATATYPE = {
    "content" : "comment",
    "spacer" : "comment",
  }
  NAME_FIELD = None
  STORAGE_KEY = None
  FIELD_ALIAS = {}
  REFERENCE_FIELDS = []
  BACKREFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = []
  OTHER_REFERENCES = []

Comment._apply_definitions()
