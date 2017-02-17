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
         "gfa2" : ["E", "G", "F", "O", "U", None]},
      "generic" : ["H", "#"],
      "different" : ["S"]
    }
  """
  Dependency of record type from version
  - specific => only for a specific version
  - generic => same syntax for all versions
  - different => different syntax in different versions
  """

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
    if not hasattr(self.__class__, "RECORD_TYPE"):
      raise gfapy.RuntimeError("This class shall not be directly instantiated")
    self.vlevel = vlevel
    self._virtual = virtual
    self._datatype = {}
    self._data = {}
    self._gfa = None
    self._version = version
    self._refs = {}
    if isinstance(data, dict):
      self._data.update(data)
    else:
      # normal initialization, data is an array of strings
      if self.version is None:
        self._process_unknown_version(data)
      else:
        self._validate_version()
        self._initialize_positional_fields(data)
        self._initialize_tags(data)
      if self.vlevel >= 1:
        self._validate_record_type_specific_info()
      if self.version is None:
        raise "RECORD_TYPE_VERSION has no value for {}".format(self.record_type)

  def to_gfa_line(self, vlevel = None, version = None):
    """
    Parameters
    ----------
    vlevel : bool
      ignored (compatibility reasons)
    version : bool
      ignored (compatibility reasons)

    Returns
    -------
    gfapy.Line
      self
    """
    return self

  def _process_unknown_version(self, data):
    rt = self.__class__.RECORD_TYPE
    if rt in Init.RECORD_TYPE_VERSIONS["generic"]:
      self._version = "generic"
      self._initialize_positional_fields(data)
      self._initialize_tags(data)
      return
    for k, v in Init.RECORD_TYPE_VERSIONS["specific"].items():
      if rt in v:
        self._version = k
        self._initialize_positional_fields(data)
        self._initialize_tags(data)
        return
    if rt in Init.RECORD_TYPE_VERSIONS["different"]:
      raise gfapy.RuntimeError(
        "GFA version not specified\n"+
        "Records of type {} ".format(rt)+
        "have different syntax according to the version")

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
    if self.version is None:
      raise gfapy.AssertionError(
        "Bug found, please report\n"+
        "strings: {}".format(repr(strings)))
    if (self.vlevel >= 1) and (len(strings) < self._n_positional_fields):
      raise gfapy.FormatError(
        "{} positional fields expected, ".format(self._n_positional_fields) +
        "{} found\n{}".format(len(strings), repr(strings)))
    for i in range(self._n_positional_fields):
      n = self.__class__.POSFIELDS[i]
      self._init_field_value(n, self.__class__.DATATYPE[n], strings[i],
                       errmsginfo = strings)

  def _initialize_tags(self, strings):
    for i in range(self._n_positional_fields, len(strings)):
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

  @classmethod
  def subclass(cls, record_type, version = None):
    """
    Select a subclass based on the record type.

    Parameters
    ----------
    version : gfapy.VERSIONS, optional
      GFA version, None if unknown.

    Raises
    ------
    gfapy.TypeError
      If the record_type is not valid.
    gfapy.VersionError
      If the version is unknown.

    Returns
    -------
    Class
      A subclass of gfapy.Line
    """
    if version == "gfa1":
      return gfapy.Line.subclass_GFA1(record_type)
    elif version == "gfa2":
      return gfapy.Line.subclass_GFA2(record_type)
    elif version is None:
      return gfapy.Line.subclass_unknown_version(record_type)
    else:
      raise gfapy.VersionError(
          "GFA specification version unknown ({})".format(version))

  @classmethod
  def subclass_GFA1(cls, record_type):
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

  @classmethod
  def subclass_GFA2(cls, record_type):
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

  @classmethod
  def subclass_unknown_version(cls, record_type):
    if record_type == "H": return gfapy.line.Header
    elif record_type == "S": return gfapy.line.segment.Factory
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

  @staticmethod
  def from_string(string, vlevel = 1, version = None):
    """
    Parses a line of a GFA file and creates an object of the correct
    record type child class of {gfapy.Line}

    Returns
    -------
    Subclass of gfapy.Line

    Raises
    ------
    gfapy.Error
      If the fields do not comply to the GFA specification.

    Parameters
    ----------
    vlevel : int, optional
      *(defaults to: 1)*
      See gfapy.Line.initialize
    version : gfapy.VERSIONS, optional
      GFA version, None if unknown.
    """
    if string[0] == "#":
      match = re.match(r"^#(\s*)(.*)$", string)
      return gfapy.line.Comment([match.group(2), match.group(1)],
                                 vlevel = vlevel,
                                 version = version)
    else:
      return gfapy.Line.from_list(string.split(gfapy.Line.SEPARATOR),
          vlevel = vlevel, version = version)

  @staticmethod
  def from_list(lst, vlevel = 1, version = None):
    """
    Parses an array containing the fields of a GFA file line and creates an
    object of the correct record type child class of {gfapy.Line}

    .. note::
      This method modifies the content of the array; if you still
      need the array, you must create a copy before calling it.

    Returns
    -------
    Subclass of gfapy.Line

    Raises
    ------
    gfapy.Error
      If the fields do not comply to the GFA specification.

    Parameters
    ----------
    vlevel : int, optional
      *(defaults to: 1)*
      See gfapy.Line#initialize
    version : gfapy.VERSIONS, optional
      GFA version, None if unknown.
    """
    sk = gfapy.Line.subclass(lst[0], version = version)
    if sk == gfapy.line.CustomRecord:
      return sk(lst, vlevel = vlevel, version = version)
    else:
      return sk(lst[1:], vlevel = vlevel, version = version)
