import gfapy
import re

class Init:

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

  def __init__(self, data, validate = 2, virtual = False, version = None):
    """
    Parameters
    ----------
    data : str list
      The content of the line.
      If data is a list of strings, this is interpreted as the splitted content
      of a GFA file line.
      Note: an hash is also allowed, but this is for internal usage
            and shall be considered private!
    validate : int
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

    The default is 2, i.e. if a field content is changed, the user is
    responsible to call **validate_field**, if necessary.

    - 0: no validation
    - 1: basic validations (number of positional fields,
    duplicated tags, tag types); some field contents are validated
    - 2: basic validations; initialization or first-access validation
    of all fields
    - 3: as 2, plus record-type specific cross-field validations
    (e.g. compare GFA1 segment LN tag and sequence lenght)
    - 4: as 3, plus field validation on writing to string
    - 5: complete validation;
    as 4, plus field validation on all access (get/set)
    """
    if not hasattr(self.__class__, "RECORD_TYPE"):
      raise gfapy.RuntimeError("This class shall not be directly instantiated")
    self.validate = validate
    self.virtual = virtual
    self.datatype = {}
    self.data = {}
    self._gfa = None
    self._version = version
    if isinstance(data, dict):
      self.data.update(data)
    else:
      # normal initialization, data is an array of strings
      if self.version is None:
        self._process_unknown_version(data)
      else:
        self._validate_version()
        self._initialize_positional_fields(data)
        self._initialize_tags(data)
      if self.validate >= 3:
        self._validate_record_type_specific_info()
      if self.version is None:
        raise "RECORD_TYPE_VERSION has no value for {}".format(self.record_type)

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
        "Records of type {} have different syntax according to the version".format(rt))

  def _validate_version(self):
    rt = self.__class__.RECORD_TYPE
    if self.version not in gfapy.VERSIONS:
      raise gfapy.VersionError(
            "GFA specification version unknown ({})".format(self.version))
    else:
      for k, v in Init.RECORD_TYPE_VERSIONS["specific"].items():
        if rt in v:
          if self.version != k:
            raise gfapy.VersionError(
              "Records of type {} are incompatible ".format(self.record_type)+
              "with version {}".format(self.version))
          return

  @property
  def _n_positional_fields(self):
    return len(self.POSFIELDS)

  def _init_field_value(self, n ,t, s, errmsginfo = None):
    if self.validate >= 3:
      s = gfapy.field.parse_gfa_field(s, t, safe = True, fieldname = n,
                            line = errmsginfo)
    elif t not in self.DELAYED_PARSING_DATATYPES:
      s = gfapy.field.parse_gfa_field(s, t, safe = (self.validate >= 2), fieldname = n,
                            line = errmsginfo)
    self.data[n] = s

  def _initialize_positional_fields(self, strings):
    if self.version is None:
      raise gfapy.AssertionError(
        "Bug found, please report\n"+
        "strings: {}".format(repr(strings)))
    if (self.validate >= 1) and (len(strings) < self._n_positional_fields):
      raise gfapy.FormatError(
        "{} positional fields expected, ".format(self._n_positional_fields) +
        "{} found\n{}".format(len(strings), repr(strings)))
    for i in range(self._n_positional_fields):
      n = self.__class__.POSFIELDS[i]
      self._init_field_value(n, self.__class__.DATATYPE[n], strings[i],
                       errmsginfo = strings)

  def _initialize_tags(self, strings):
    for i in range(self._n_positional_fields, len(strings)):
      self._initialize_tag(*(gfapy.field.parse_gfa_tag(strings[i])), errmsginfo = strings)

  def _initialize_tag(self, n, t, s, errmsginfo = None):
    if (self.validate > 0):
      if n in self.data:
        raise gfapy.NotUniqueError(
          "Tag {} found multiple times".format(n))
      elif self._predefined_tag(n):
        if t != self.__class__.DATATYPE[n]:
          raise gfapy.TypeError(
            "Tag {} must be of type ".format(n) +
            "{}, {} found".format(self.__class__.DATATYPE[n], t))
      elif (not self.is_valid_custom_tagname(n)):
        raise gfapy.FormatError(
          "Custom tags must be lower case; found: {}".format(n))
      else:
        self.datatype[n] = t
    else:
      if not self.field_datatype(t):
        self.datatype[n] = t
    self._init_field_value(n, t, s, errmsginfo = errmsginfo)

  @staticmethod
  def from_string(string, validate = 2, version = None):
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
    validate : int, optional
      *(defaults to: 2)*
      See gfapy.Line.initialize
    version : gfapy.VERSIONS, optional
      GFA version, None if unknown.
    """
    if string[0] == "#":
      match = re.match(r"^#(\s*)(.*)$", string)
      return gfapy.line.Comment([match.group(2), match.group(1)],
                                 validate = validate,
                                 version = version)
    else:
      return gfapy.Line.from_list(string.split(gfapy.Line.SEPARATOR), validate = validate, version = version)

  @staticmethod
  def from_list(lst, validate = 2, version = None):
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
    validate : int, optional
      *(defaults to: 2)*
      See gfapy.Line#initialize
    version : gfapy.VERSIONS, optional
      GFA version, None if unknown.
    """
    sk = gfapy.Line.subclass(lst[0], version = version)
    if sk == gfapy.line.CustomRecord:
      return sk(lst, validate = validate, version = version)
    else:
      return sk(lst[1:], validate = validate, version = version)


  @classmethod
  def subclass(self, record_type, version = None):
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
      return self.subclass_GFA1(record_type)
    elif version == "gfa2":
      return self.subclass_GFA2(record_type)
    elif version == None:
      return self.subclass_unknown_version(record_type)
    else:
      raise gfapy.VersionError(
          "GFA specification version unknown ({})".format(version))

  @classmethod
  def subclass_GFA1(self, record_type):
    if str(record_type) == "H": return gfapy.line.Header
    elif str(record_type) == "S": return gfapy.line.segment.GFA1
    elif str(record_type) == "#": return gfapy.line.Comment
    elif str(record_type) == "L": return gfapy.line.edge.Link
    elif str(record_type) == "C": return gfapy.line.edge.Containment
    elif str(record_type) == "P": return gfapy.line.group.Path
    else:
      raise gfapy.TypeError("Record type unknown: '{}'".format(record_type))

  @classmethod
  def subclass_GFA2(self, record_type):
    if str(record_type) == "H": return gfapy.line.Header
    elif str(record_type) == "S": return gfapy.line.segment.GFA2
    elif str(record_type) == "#": return gfapy.line.Comment
    elif str(record_type) == "E": return gfapy.line.edge.GFA2
    elif str(record_type) == "F": return gfapy.line.Fragment
    elif str(record_type) == "G": return gfapy.line.Gap
    elif str(record_type) == "O": return gfapy.line.group.Ordered
    elif str(record_type) == "U": return gfapy.line.group.Unordered
    else: return gfapy.line.CustomRecord

  @classmethod
  def subclass_unknown_version(self, record_type):
    if str(record_type) == "H": return gfapy.line.Header
    elif str(record_type) == "S": return gfapy.line.segment.Factory
    elif str(record_type) == "#": return gfapy.line.Comment
    elif str(record_type) == "L": return gfapy.line.edge.Link
    elif str(record_type) == "C": return gfapy.line.edge.Containment
    elif str(record_type) == "P": return gfapy.line.group.Path
    elif str(record_type) == "E": return gfapy.line.edge.GFA2
    elif str(record_type) == "F": return gfapy.line.Fragment
    elif str(record_type) == "G": return gfapy.line.Gap
    elif str(record_type) == "O": return gfapy.line.group.Ordered
    elif str(record_type) == "U": return gfapy.line.group.Unordered
    else: return gfapy.line.CustomRecord
