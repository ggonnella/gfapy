from .common.construction import Construction
from .common.dynamic_fields import DynamicFields, DynamicField
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

import gfapy

class Line(Construction, DynamicFields, Writer, VersionConversion,
           FieldDatatype, FieldData, Equivalence, Cloning, Connection,
           VirtualToReal, UpdateReferences, Disconnection, Validate,
           DefaultRecordDefinition):
  """
  A line of a GFA file.
  """

  SEPARATOR = "\t"
  """Separator in the string representation of GFA lines"""

