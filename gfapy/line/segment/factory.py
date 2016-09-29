from . import Segment
import gfapy

class Factory(Segment):
  """
  Factory of instances of the classes
  gfapy.Line.Segment.GFA1 and
  gfapy.Line.Segment.GFA2
  """

  def __new__(cls, data, validate = 2, virtual = False, version = None):
    if version == "gfa1":
      return gfapy.line.segment.GFA1(data,
               validate = validate, virtual = virtual, version = version)
    elif version == "gfa2":
      return gfapy.line.segment.GFA2(data,
               validate = validate, virtual = virtual, version = version)
    elif version is None:
      try:
        return gfapy.line.segment.GFA1(data,
                 validate = validate, virtual = virtual, version = "gfa1")
      except Exception as err_gfa1:
        try:
          return gfapy.line.segment.GFA2(data,
                   validate = validate, virtual = virtual, version = "gfa2")
        except Exception as err_gfa2:
          raise gfapy.FormatError(
            "The segment line has an invalid format for both GFA1 and GFA2\n"+
            "GFA1 Error: {}\n".format(err_gfa1.__class__)+
            "{}\n".format(str(err_gfa1))+
            "GFA2 Error: {}\n".format(err_gfa2.__class__)+
            "{}\n".format(str(err_gfa2)))
    else:
      raise gfapy.VersionError(
        "GFA specification version unknown ({})".format(version))
