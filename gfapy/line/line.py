from .common.init import Init
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
from functools import partial

try:
  from functools import partialmethod
except ImportError:
  #for compatibility with old python versions
  def partialmethod(method, **kwargs):
    return lambda self: method(self, **kwargs)

class Line(Init, DynamicFields, Writer, VersionConversion, FieldDatatype, FieldData,
           Equivalence, Cloning, Connection, VirtualToReal, UpdateReferences,
           Disconnection, Validate):
  """
  Generic representation of a record of a GFA file.

  .. note::
    This class is usually not meant to be directly initialized by the user;
    initialize instead one of its child classes, which define the concrete
    different record types.
  """

  SEPARATOR = "\t"
  """Separator in the string representation of GFA lines"""

  RECORD_TYPES = [ "H", "S", "L", "C", "P", "#", "G", "F", "E", "O", "U", None ]
  """List of allowed record_type values"""

  DIRECTION = ["from", "to"]
  """Direction of a segment for links/containments"""

  ORIENTATION = ["+", "-"]
  """Orientation of segments in paths/links/containments"""

  @property
  def version(self):
    """
    Returns
    -------
    gfapy.VERSIONS, None
      GFA specification version
    """
    return self._version

  @property
  def record_type(self):
    """
    Returns
    -------
    str
      Record type code.
    """
    return self.__class__.RECORD_TYPE

  def to_gfa_line(self, validate = None, version = None):
    """
    Parameters
    ----------
    validate : bool
      ignored (compatibility reasons)
    version : bool
      ignored (compatibility reasons)

    Returns
    -------
    gfapy.Line
      self
    """
    return self

  @classmethod
  def __define_field_methods(cls):
    """
    This avoids calls for fields which are already defined
    """
    for fieldname in cls.POSFIELDS + cls.PREDEFINED_TAGS:
      def get_method(self, fieldname):
        return self.get(fieldname)
      def try_get_method(self, fieldname):
        return self.try_get(fieldname)
      def set_method(self, value, fieldname):
        return self._set_existing_field(fieldname, value)
      setattr(cls, fieldname, DynamicField(partial(get_method, fieldname = fieldname), 
                                           partial(set_method, fieldname = fieldname)))
      setattr(cls, "try_get_" + fieldname, 
              partialmethod(try_get_method, fieldname = fieldname))
    for k,v in cls.FIELD_ALIAS.items():
      setattr(cls, k, getattr(cls, v))
      setattr(cls, "try_get_" + k, getattr(cls, "try_get_" + v))
    for k in cls.DEPENDENT_LINES + cls.OTHER_REFERENCES:
      def method(self, k):
        if not self.refs:
          self.refs = {}
        return self.refs.get(k , [])
      setattr(cls, k, partialmethod(method, k = k))
    def all_references(self):
      return [ item for item in values for values in self.refs ]

# Moved to __init__.py
##
## import the child classes
##
#from .header import Header
#from .segment import Segment
#from .comment import Comment
#from .gap import Gap
#from .fragment import Fragment
#from .edge import Edge
#from .unknown import Unknown
