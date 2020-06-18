from ..line import Line
from .construction import Construction
from .tags import Tags
from .writer import Writer
from .version_conversion import VersionConversion

class Comment(Writer, Tags, Construction, VersionConversion, Line):
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
  DATATYPE = {
    "content" : "comment",
    "spacer" : "comment",
  }

Comment._apply_definitions()
