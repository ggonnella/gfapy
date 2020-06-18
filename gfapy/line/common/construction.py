from collections import OrderedDict
from functools import partial
import re
import gfapy
from .dynamic_fields import DynamicField

try:
  from functools import partialmethod
except ImportError:
  #for compatibility with old python versions
  def partialmethod(method, **kwargs):
    return lambda self: method(self, **kwargs)

class Construction:

  DELAYED_PARSING_DATATYPES = [
                                "alignment_gfa1",
                                "alignment_gfa2",
                                "alignment_list_gfa1",
                                "oriented_segments",
                                "H",
                                "J",
                                "B",
                              ]
  """
  List of datatypes which are parsed only on access.

  All other are parsed when read.
  """

  RECORD_TYPE_VERSIONS = {
      "specific" :
        {"gfa1" : ["C", "L", "P"],
         "gfa2" : ["E", "G", "F", "O", "U", "\n"]},
      "generic" : ["H", "#"],
      "different" : ["S"]
    }
  """
  Dependency of record type from version.

  * specific: only for a specific version
  * generic:  same syntax for all versions
  * different: different syntax in different versions
  """

  def __new__(cls, data, vlevel = 1, virtual = False, dialect = "standard",
      version = None):
    if isinstance(data, str):
      data = data.split("\t")
    if isinstance(data, list) and cls.RECORD_TYPE == None:
      cls = gfapy.Line._subclass(data, version = version)
    return object.__new__(cls)

  def __init__(self, data, vlevel = 1, virtual = False,
               version = None, dialect = "standard"):
    self._dialect = dialect.lower()
    self.vlevel = vlevel
    self._virtual = virtual
    self._datatype = {}
    self._data = {}
    self._gfa = None
    self._version = version
    self._refs = {}
    if self.__class__ == gfapy.Line:
      raise gfapy.AssertionError("Line subclass unknown")
    if isinstance(data, dict):
      # API private initialization using dict
      self._data.update(data)
    else:
      # public initialization using list (or tab-separated string)
      if self.__class__ == gfapy.line.Comment:
        data = gfapy.Line._init_comment_data(data)
      elif isinstance(data, str):
        data = data.split(gfapy.Line.SEPARATOR)
      if self.version is None:
        self._compute_version(data[0])
      else:
        self._validate_version()
      self._initialize_positional_fields(data)
      self._initialize_tags(data)
      if self.vlevel >= 1:
        self._validate_record_type_specific_info()
      if self.version is None:
        raise gfapy.RuntimeError("version could not be determined, "+
            "record_type={}".format(self.record_type))

  @staticmethod
  def _init_comment_data(data):
    if isinstance(data, list) and (data[0] != "#"):
      # unproperly splitten, rejoin
      data = "\t".join(data)
    if isinstance(data, str):
      match = re.match(r"^#(\s*)(.*)$", data)
      if match is None:
        raise gfapy.FormatError("Comment lines must begin with #\n"+
            "Line: {}".format(data))
      data = ["#", match.group(2), match.group(1)]
    return data

  def _compute_version(self, rt):
    if rt in Construction.RECORD_TYPE_VERSIONS["generic"]:
      self._version = "generic"
    elif rt in Construction.RECORD_TYPE_VERSIONS["different"]:
      if hasattr(self.__class__, "VERSION"):
        self._version = self.__class__.VERSION
      else:
        raise gfapy.RuntimeError(
            "GFA version not specified\n"+
            "Records of type {} ".format(rt)+
            "have different syntax according to the version")
    else:
      for k, v in Construction.RECORD_TYPE_VERSIONS["specific"].items():
        if rt in v:
          self._version = k
          break
    if not self._version:
      self._version = "gfa2"

  def _validate_version(self):
    rt = self.__class__.RECORD_TYPE
    if self._version not in gfapy.VERSIONS:
      raise gfapy.VersionError(
            "GFA specification version unknown ({})".format(self._version))
    else:
      for k, v in Construction.RECORD_TYPE_VERSIONS["specific"].items():
        if rt in v:
          if self._version != k:
            raise gfapy.VersionError(
              "Records of type {} are incompatible ".format(self.record_type)+
              "with version {}".format(self._version))
          return

  @property
  def _n_positional_fields(self):
    return len(self.POSFIELDS)

  def _init_field_value(self, n ,t, s, errmsginfo = None):
    if self.vlevel >= 1:
      s = gfapy.Field._parse_gfa_field(s, t, safe = True, fieldname = n,
                            line = errmsginfo)
    elif t not in self.DELAYED_PARSING_DATATYPES:
      s = gfapy.Field._parse_gfa_field(s, t, safe = (self.vlevel >= 1),
            fieldname = n, line = errmsginfo)
    self._data[n] = s

  def _initialize_positional_fields(self, strings):
    if strings[0] != self.RECORD_TYPE and self.RECORD_TYPE != "\n":
      raise gfapy.FormatError("Record type of records of "+
          "class {} must be {} ({} found)".format(self.__class__,
            self.RECORD_TYPE, strings[0]))
    if self.version is None:
      raise gfapy.AssertionError(
        "Bug found, please report\n"+
        "strings: {}".format(repr(strings)))
    if (self.vlevel >= 1) and (len(strings)-1 < self._n_positional_fields):
      raise gfapy.FormatError(
        "{} positional fields expected, ".format(self._n_positional_fields) +
        "{} found\n{}".format(len(strings)-1, repr(strings)))
    for i, n in enumerate(self.POSFIELDS):
      self._init_field_value(n, self.__class__.DATATYPE[n], strings[i+1],
                       errmsginfo = strings)

  def _initialize_tags(self, strings):
    for i in range(len(self.POSFIELDS)+1, len(strings)):
      self._initialize_tag(*(gfapy.Field._parse_gfa_tag(strings[i])),
          errmsginfo = strings)

  def _initialize_tag(self, n, t, s, errmsginfo = None):
    if (self.vlevel > 0):
      if n in self._data:
        raise gfapy.NotUniqueError(
          "Tag {} found multiple times".format(n))
      elif self._is_predefined_tag(n):
        self._validate_predefined_tag_type(n, t)
      else:
        self._validate_custom_tagname(n)
        self._datatype[n] = t
    else:
      if not self._field_datatype(t):
        self._datatype[n] = t
    self._init_field_value(n, t, s, errmsginfo = errmsginfo)

  @staticmethod
  def _subclass(data, version = None):
    record_type = data[0]
    if record_type and record_type[0] == "#":
      return gfapy.line.Comment
    elif version == "gfa1":
      return gfapy.Line._subclass_GFA1(record_type)
    elif version == "gfa2":
      return gfapy.Line._subclass_GFA2(record_type)
    elif version is None:
      return gfapy.Line._subclass_unknown_version(data)
    else:
      raise gfapy.VersionError(
          "GFA specification version unknown ({})".format(version))

  @staticmethod
  def _subclass_GFA1(record_type):
    if record_type is None:
      raise gfapy.VersionError(
          "gfapy uses virtual records of unknown type for GFA2 only")
    if record_type == "H": return gfapy.line.Header
    elif record_type == "S": return gfapy.line.segment.GFA1
    elif record_type == "#": return gfapy.line.Comment
    elif record_type == "L": return gfapy.line.edge.Link
    elif record_type == "C": return gfapy.line.edge.Containment
    elif record_type == "P": return gfapy.line.group.Path
    else:
      raise gfapy.VersionError(
          "Custom record types are not supported in GFA1: '{}'".format(
            record_type))

  EXTENSIONS = {}
  """Extensions (definition of custom record types) registered by the user."""

  @staticmethod
  def _subclass_GFA2(record_type):
    if record_type == "H": return gfapy.line.Header
    elif record_type == "S": return gfapy.line.segment.GFA2
    elif record_type == "#": return gfapy.line.Comment
    elif record_type == "E": return gfapy.line.edge.GFA2
    elif record_type == "F": return gfapy.line.Fragment
    elif record_type == "G": return gfapy.line.Gap
    elif record_type == "O": return gfapy.line.group.Ordered
    elif record_type == "U": return gfapy.line.group.Unordered
    elif record_type in gfapy.Line.EXTENSIONS:
      return gfapy.Line.EXTENSIONS[record_type]
    else: return gfapy.line.CustomRecord

  @staticmethod
  def _subclass_unknown_version(data):
    record_type = data[0]
    if record_type == "H": return gfapy.line.Header
    elif record_type == "S": return gfapy.line.Segment._subclass(data)
    elif record_type == "#": return gfapy.line.Comment
    elif record_type == "L": return gfapy.line.edge.Link
    elif record_type == "C": return gfapy.line.edge.Containment
    elif record_type == "P": return gfapy.line.group.Path
    elif record_type == "E": return gfapy.line.edge.GFA2
    elif record_type == "F": return gfapy.line.Fragment
    elif record_type == "G": return gfapy.line.Gap
    elif record_type == "O": return gfapy.line.group.Ordered
    elif record_type == "U": return gfapy.line.group.Unordered
    elif record_type in gfapy.Line.EXTENSIONS:
      return gfapy.Line.EXTENSIONS[record_type]
    else: return gfapy.line.CustomRecord

  @classmethod
  def _apply_definitions(cls):
    """
    This avoids calls for fields which are already defined
    """
    cls._define_field_accessors()
    cls._define_field_aliases()
    cls._define_reference_getters()

  @classmethod
  def _define_field_accessors(cls):
    if not cls.PREDEFINED_TAGS:
      cls.PREDEFINED_TAGS = list(set(cls.DATATYPE.keys()) - set(cls.POSFIELDS))
    fieldnames = cls.POSFIELDS + cls.PREDEFINED_TAGS
    if cls.NAME_FIELD and cls.NAME_FIELD not in fieldnames:
      fieldnames.append(cls.NAME_FIELD)
    for fieldname in fieldnames:
      def get_method(self, fieldname):
        return self.get(fieldname)
      def set_method(self, value, fieldname):
        return self._set_existing_field(fieldname, value)
      setattr(cls, fieldname,
          DynamicField(partial(get_method, fieldname = fieldname),
                       partial(set_method, fieldname = fieldname)))
      def try_get_method(self, fieldname):
        return self.try_get(fieldname)
      setattr(cls, "try_get_" + fieldname,
              partialmethod(try_get_method, fieldname = fieldname))

  @classmethod
  def _define_field_aliases(cls):
    if cls.STORAGE_KEY is None and cls.NAME_FIELD is not None:
      cls.STORAGE_KEY = "name"
    if cls.FIELD_ALIAS is None:
      cls.FIELD_ALIAS = {}
    if cls.NAME_FIELD is not None and "name" not in cls.POSFIELDS:
      cls.FIELD_ALIAS["name"] = cls.NAME_FIELD
    for k,v in cls.FIELD_ALIAS.items():
      setattr(cls, k, getattr(cls, v))
      setattr(cls, "try_get_" + k, getattr(cls, "try_get_" + v))

  @classmethod
  def _define_reference_getters(cls):
    for k in cls.DEPENDENT_LINES + cls.OTHER_REFERENCES:
      def get_method(self, k):
        return self._refs.get(k , [])
      def set_method(self, value, k):
        raise gfapy.AttributeError(
            "References collections cannot be set directly")
      setattr(cls, k,
          DynamicField(partial(get_method, k = k),
                       partial(set_method, k = k)))
    def all_references(self):
      return [ item for item in [ values for values in self._refs ] ]

  @classmethod
  def register_extension(cls, references=[]):
    # check the definitions
    if isinstance(cls.POSFIELDS,OrderedDict):
      for fieldname, datatype in cls.POSFIELDS.items():
        cls.DATATYPE[fieldname] = datatype
      cls.POSFIELDS = list(cls.POSFIELDS.keys())
    else:
      for posfield in cls.POSFIELDS:
        if posfield not in cls.DATATYPE:
          raise gfapy.RuntimeError("Extension {} ".format(str(cls))+
              "defines no datatype for the positional field {}".format(posfield))
    if hasattr(cls, "TAGS_DATATYPE"):
      for fieldname, datatype in cls.TAGS_DATATYPE.items():
        cls.DATATYPE[fieldname] = datatype
    if not cls.RECORD_TYPE:
      raise gfapy.RuntimeError("Extension {} ".format(str(cls))+
            "does not define the RECORD_TYPE constant")
    if cls.NAME_FIELD is not None:
      gfapy.lines.finders.Finders.RECORDS_WITH_NAME.append(cls.RECORD_TYPE)
    for field, klass, refkey in references:
      if field not in cls.REFERENCE_FIELDS:
        if not cls.REFERENCE_FIELDS:
          cls.REFERENCE_FIELDS = []
        cls.REFERENCE_FIELDS.append(field)
      if refkey not in klass.DEPENDENT_LINES:
        klass.DEPENDENT_LINES.append(refkey)
        klass._define_reference_getters()
      if cls.REFERENCE_INITIALIZERS is None:
        cls.REFERENCE_INITIALIZERS = []
      cls.REFERENCE_INITIALIZERS.append((field, klass, refkey))
    cls._apply_definitions()
    gfapy.Line.EXTENSIONS[cls.RECORD_TYPE] = cls
    gfapy.Line.RECORD_TYPE_VERSIONS["specific"]["gfa2"].append(cls.RECORD_TYPE)

