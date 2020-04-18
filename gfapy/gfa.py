import gfapy
from .lines import Lines
from .graph_operations import GraphOperations
from collections import defaultdict
from .rgfa import RGFA
import sys

class Gfa(Lines,GraphOperations,RGFA):
  """Representation of the data in a GFA file.

  Parameters:
    data (str or list): optional, string content of a GFA file, or
       the same as a list (splitted on newlines); default: create an empty Gfa
       instance
    vlevel (int): validation level (default: 1)
    version (str): GFA version ('gfa1' or 'gfa2';
        default: automatic recognition)
    dialect (str): dialect ('standard' or 'rgfa';
        default: standard)

  Raises:
    ~gfapy.error.ArgumentError: if the vlevel or version are invalid
    ~gfapy.error.FormatError: if data is provided, which is invalid
    ~gfapy.error.VersionError: if an unknown version is specified, or data is
        provided, which is not compatible with the specified version
    ~gfapy.error.VersionError: if an unknown dialect is specified
  """

  def __init__(self, *args, vlevel = 1, version = None, dialect = "standard"):
    if not isinstance(vlevel, int):
      raise gfapy.ArgumentError("vlevel is not an integer ({})".format(vlevel))
    if vlevel < 0:
      raise gfapy.ArgumentError(
          "vlevel is not a positive integer ({})".format(vlevel))
    if not version in ['gfa1', 'gfa2', None]:
      raise gfapy.VersionError("GFA version unknown ({})".format(version))
    if not dialect in ['standard', 'rgfa', None]:
      raise gfapy.VersionError("GFA dialect unknown ({})".format(dialect))
    self._vlevel = vlevel
    self._max_int_name = 0
    self._records = defaultdict(dict)
    self._records["H"] = gfapy.line.Header(["H"], vlevel = vlevel)
    self._records["H"].connect(self)
    self._records["S"] = {}
    self._records["P"] = {}
    self._records["F"] = {}
    self._records["\n"] = {}
    self._records["E"] = {}
    self._records["U"] = {}
    self._records["G"] = {}
    self._records["O"] = {}
    self._records["C"] = {}
    self._records["L"] = {}
    self._records["#"] = {}
    self._segments_first_order = False
    self._progress = None
    self._default = {"count_tag": "RC", "unit_length": 1}
    self._line_queue = []
    if version is None:
      self._version = None
      self._version_explanation = None
      self._version_guess = "gfa2"
    else:
      self._version = version
      self._version_explanation = "set during initialization"
      self._version_guess = version
      self._validate_version()
    self._dialect = dialect.lower()
    if len(args) == 1:
      lst = None
      if isinstance(args[0], str):
        lst = args[0].split("\n")
      elif isinstance(args[0], list):
        lst = args[0]
      else:
        raise gfapy.ArgumentError("Cannot create a Gfa"+
            " instance from an object of type {}".format(type(args[0])))
      for line in lst:
          self.add_line(line)
      self.process_line_queue()
      if vlevel >= 1:
        self.validate()
    elif len(args) > 1:
      raise gfapy.ArgumentError("Wrong number of arguments for Gfa()"+
          "({})".format(len(args)))

  @property
  def version(self):
    """GFA version ('gfa1' or 'gfa2')"""
    return self._version

  @version.setter
  def version(self,value):
    self._version=value

  @property
  def dialect(self):
    """GFA dialect ('standard' or 'rgfa')"""
    return self._dialect

  @dialect.setter
  def dialect(self, value):
    self._dialect = value.lower()

  @property
  def vlevel(self):
    """Level of validation"""
    return self._vlevel

  @vlevel.setter
  def vlevel(self,value):
    self._vlevel=value

  def validate(self):
    """Validate the GFA instance

    Checks if all references are solved correctly.
    """
    self.__validate_segment_references()
    self.__validate_path_links()
    self.__validate_group_items()
    self.__validate_gfa2_positions()
    if self._dialect == "rgfa":
      self.validate_rgfa()

  def __str__(self):
    return "\n".join([str(line) for line in self.lines])

  def to_gfa1_s(self):
    """Create a GFA1 string representation for the GFA data

    If the Gfa has version 'gfa1', its string representation is
    returned. Otherwise a conversion from GFA2 is performed.
    """
    if self.version == "gfa1":
      return str(self)
    else:
      lines = []
      for line in self.lines:
        converted = line.to_gfa1_s()
        if converted:
          lines.append(converted)
      return "\n".join(lines)

  def to_gfa1(self):
    """Create a GFA1 Gfa instance for the GFA data

    If the Gfa has version 'gfa1', it is
    returned. Otherwise a conversion from GFA2 is performed.
    """
    if self.version == "gfa1":
      return self
    else:
      gfa1 = gfapy.Gfa(version="gfa1", vlevel=self.vlevel)
      for line in self.lines:
        gfa1.add_line(line.to_gfa1(raise_on_failure=False))
      return gfa1

  def to_gfa2_s(self):
    """Create a GFA2 string representation for the GFA data

    If the Gfa has version 'gfa2', its string representation is
    returned. Otherwise a conversion from GFA1 is performed.
    """
    if self.version == "gfa2":
      return str(self)
    else:
      lines = []
      for line in self.lines:
        converted = line.to_gfa2_s()
        if converted:
          lines.append(converted)
      return "\n".join(lines)

  def to_gfa2(self):
    """Create a GFA2 Gfa instance for the GFA data.

    If the Gfa has version 'gfa2', it is
    returned. Otherwise a conversion from GFA1 is performed.
    """
    if self.version == "gfa2":
      return self
    else:
      gfa2 = gfapy.Gfa(version="gfa2", vlevel=self.vlevel)
      for line in self.lines:
        gfa2.add_line(line.to_gfa2(raise_on_failure=False))
      return gfa2

  # TODO: implement clone (see how clone for lines was implemented)

  def read_file(self, filename):
    """Read GFA data from a file and load it into the Gfa instance.

    Parameters:
      filename (str)
    """
    if self._progress:
      linecount = 0
      with open(filename) as f:
        for line in f:
          linecount += 1
      # TODO: better implementation of linecount
      self._progress_log_init("read_file", "lines", linecount,
                              "Parsing file {}".format(filename)+
                              " containing {} lines".format(linecount))
    with open(filename) as f:
      for line in f:
        self.add_line(line.rstrip('\r\n'))
        if self._progress:
          self._progress_log("read_file")
    if self._line_queue:
      self._version = self._version_guess
      self.process_line_queue()
    if self._progress:
      self._progress_log_end("read_file")
    if self._vlevel >= 1:
      self.validate()
    return self

  @classmethod
  def from_file(cls, filename, vlevel = 1, version = None, dialect="standard"):
    """Create a Gfa instance from the contents of a GFA file.

    Parameters:
      filename (str)
      vlevel (int) : the validation level
      version (str) : the GFA version ('gfa1' or 'gfa2'; default:
          determine version automatically)

    Returns:
      gfapy.Gfa
    """
    gfa = cls(vlevel = vlevel, version = version, dialect = dialect)
    gfa.read_file(filename)
    return gfa

  def to_file(self, filename):
    """Write the content of the instance to a GFA file

    Parameters:
      filename (str)
    """
    with open(filename, "w") as f:
      for line in self.lines:
        f.write(str(line)+"\n")

  def __eq__(self, other):
    self.lines == other.lines

  def __lenstats(self):
    sln = [ s.try_length for s in self.segments ]
    sln = sorted(sln)
    n = len(sln)
    tlen = 0
    for l in sln:
      tlen += l
    n50_target = tlen//2
    n50 = None
    curr_sum = 0
    for l in reversed(sln):
      curr_sum += l
      if curr_sum >= n50_target:
        n50 = l
        break
    q = (sln[0], sln[(n//4)-2], sln[(n//2)-1], sln[((n*3)//4)-1], sln[-1])
    return (q, n50, tlen)

  def __validate_segment_references(self):
    for s in self.segments:
      if s.virtual:
        raise gfapy.NotFoundError("Segment {} ".format(s.name)+
            "does not exist\nReferences to {} ".format(s.name)+
            "were found in the following lines:\n"+s.refstr())

  def __validate_path_links(self):
    for pt in self._gfa1_paths:
      for ol in pt.links:
        l = ol.line
        if l.virtual:
          raise gfapy.NotFoundError("A link equivalent to:\n{}\n".format(\
                  l.to_str(add_virtual_commentary=False))+
              "does not exist, but is required by the following paths:\n"+
              l.refstr())

  def __validate_group_items(self):
    if self.version == "gfa1":
      return
    for group in self.sets + self.paths:
      for item in group.items:
        if isinstance(item, gfapy.OrientedLine):
          item = item.line
        if item.virtual:
          raise gfapy.NotFoundError("A line with identifier {}\n".format(\
                  item.name)+
              "does not exist, but is required by the following groups:\n"+
              item.refstr())

  def __validate_gfa2_positions(self):
    if self.version == "gfa1":
      return
    for line in self.edges + self.fragments:
      line.validate_positions()

  def _validate_version(self):
    if (self._version != None) and (self._version not in gfapy.VERSIONS):
      raise gfapy.VersionError("GFA specification version {} not supported".
              format(self._version))

  # Progress logging related-methods:

  def enable_progress_logging(self, part=0.1, channel=sys.stderr):
    '''Activate logging of progress for some graph operations.

    Parameters:
      part (float) : report when every specified portion of the computation
          is completed (default: 0.1)
      channel : output channel (default: standard error)
    '''
    self._progress = gfapy.Logger(channel=channel)
    self._progress.enable_progress(part=part)

  def _progress_log_init(self, symbol, units, total, initmsg = None):
    if self._progress is not None:
      self._progress.progress_init(symbol, units, total, initmsg)

  def _progress_log(self, symbol, progress=1, **keyargs):
    if self._progress is not None:
      self._progress.progress_log(symbol, progress)

  def _progress_log_end(self, symbol, **keyargs):
    if self._progress is not None:
      self._progress.progress_end(symbol)

