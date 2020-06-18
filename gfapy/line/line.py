from .common.construction import Construction
from .common.dynamic_fields import DynamicFields
from .common.writer import Writer
from .common.version_conversion import VersionConversion
from .common.field_datatype import FieldDatatype
from .common.field_data import FieldData
from .common.equivalence import Equivalence
from .common.cloning import Cloning
from .common.connection import Connection
from .common.virtual_to_real import VirtualToReal
from .common.update_references import UpdateReferences
from .common.disconnection import Disconnection
from .common.validate import Validate
from .common.default_record_definition import DefaultRecordDefinition

class Line(Construction, DynamicFields, Writer, VersionConversion,
           FieldDatatype, FieldData, Equivalence, Cloning, Connection,
           VirtualToReal, UpdateReferences, Disconnection, Validate,
           DefaultRecordDefinition):
  """
  A line of a GFA file.

  Parameters:
    data (str, list of str) : the content of a line in a GFA file, either as
      a string, or as a list derived from tab-splitting the line string
    vlevel (int) : an integer from 0 to 3, which specifies the validation level;
      if 0, no validation is performed (the user can still validate manually if
      needed); if 1 (the default), validation is performed when the line
      is constructed, or, for some fields, when the value is accessed
      for the first time; if 2, the validation is performed also when converting
      the content of a field to string; if 3, also each time the value
      of a field is read or written
    version (str) : one of 'gfa1' and 'gfa2'; the GFA version; if not specified,
      then the version is guessed from the record type and syntax, or set
      to 'generic'
    dialect (str) : one of 'rgfa' and 'standard'; the GFA dialect; if not
      specified then the dialect is set to 'standard'; 'rgfa' is only valid
      when version is 'gfa1'

  Notes:
    The private interface to the Line constructor also allows to pass a
    dictionary instead of a list for data. Furthermore the private parameter
    virtual allows to create virtual line instances, which are useful during
    parsing.

  Raises:
    gfapy.error.FormatError: If the line contains a wrong number of positional
      fields, or if the content of a field has a wrong format.
    gfapy.error.NotUniqueError: If a tag name is used more than once.
    gfapy.error.TypeError: If the value of a predefined tag does not
      respect the datatype specified in the tag.

  Returns:
    an instance of a subclass of gfapy.line.Line
  """

  SEPARATOR = "\t"
  """Separator in the string representation of GFA lines"""

