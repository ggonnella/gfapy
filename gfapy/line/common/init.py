import gfapy
import re

class Init:

  RECORD_TYPES = [ "H", "S", "L", "C", "P", "#", "G", "F", "E", "O", "U", None ]
  """List of allowed record_type values"""

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
  List of data types which are parsed only on access;
  all other are parsed when read.
  """

  RECORD_TYPE_VERSIONS = {
      "specific" :
        {"gfa1" : ["C", "L", "P"],
         "gfa2" : ["E", "G", "F", "O", "U", "\n"]},
      "generic" : ["H", "#"],
      "different" : ["S"]
    }
  """
  Dependency of record type from version
  - specific => only for a specific version
  - generic => same syntax for all versions
  - different => different syntax in different versions
  """

  def __new__(cls, data, vlevel = 1, virtual = False, version = None):
    if isinstance(data, str):
      data = data.split("\t")
    if isinstance(data, list) and cls.RECORD_TYPE == None:
      cls = gfapy.Line._subclass(data, version = version)
    return object.__new__(cls)

  def __init__(self, data, vlevel = 1, virtual = False, version = None):
    """
    Parameters
    ----------
    data : str list
      The content of the line.
      If data is a list of strings, this is interpreted as the splitted content
      of a GFA file line.
      Note: an hash is also allowed, but this is for internal usage
            and shall be considered private!
    vlevel : int
      See paragraph *Validation*.
    virtual : bool
      *(default: ***False***)*
      Mark the line as virtual, i.e. not yet found in the GFA file;
      e.g. a link is allowed to refer to a segment which is not
      yet created; in this case a segment marked as virtual is created,
      which is replaced by a non-virtual segment, when the segment
      line is later found
    version : gfapy.VERSIONS
      GFA version, None if unknown

    **Constants defined by subclasses**

    Subclasses of gfapy.Line _must_ define the following constants:
    - RECORD_TYPE [gfapy.Line.RECORD_TYPES]
    - POSFIELDS [str list] positional fields
    - FIELD_ALIAS [dict{str -> str}] alternative names for positional
    fields
    - PREDEFINED_TAGS [str list] predefined tags
    - DATATYPE [dict{str -> str}]:
    datatypes for the positional fields and the tags

    Raises
    ------
    gfapy.FormatError
      If too less positional fields are specified.
    gfapy.FormatError
      If a non-predefined tag uses upcase letters.
    gfapy.NotUniqueError
      If a tag name is used more than once.
    gfapy.TypeError
      If the type of a predefined tag does not
      respect the specified type.

    Returns
    -------
    gfapy.Line

    **Validation levels**

    - 0: no validation (validate manually if needed)
    - 1: (default) validation when parsing/accessing for the first time a field
    - 2: validation when parsing/accessing for the first time as well as
         when converting a field to string
    - 3: validation on each field access
    """
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
    if rt in Init.RECORD_TYPE_VERSIONS["generic"]:
      self._version = "generic"
    elif rt in Init.RECORD_TYPE_VERSIONS["different"]:
      if hasattr(self.__class__, "VERSION"):
        self._version = self.__class__.VERSION
      else:
        raise gfapy.RuntimeError(
            "GFA version not specified\n"+
            "Records of type {} ".format(rt)+
            "have different syntax according to the version")
    else:
      for k, v in Init.RECORD_TYPE_VERSIONS["specific"].items():
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
      for k, v in Init.RECORD_TYPE_VERSIONS["specific"].items():
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
      s = gfapy.Field.parse_gfa_field(s, t, safe = True, fieldname = n,
                            line = errmsginfo)
    elif t not in self.DELAYED_PARSING_DATATYPES:
      s = gfapy.Field.parse_gfa_field(s, t, safe = (self.vlevel >= 1),
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
      self._initialize_tag(*(gfapy.Field.parse_gfa_tag(strings[i])),
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

