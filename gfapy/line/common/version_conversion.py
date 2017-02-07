import gfapy
try:
  from functools import partialmethod
except ImportError:
  #for compatibility with old python versions
  def partialmethod(method, **kwargs):
    return lambda self: method(self, **kwargs)

class VersionConversion:
  pass

for shall_version in ["gfa1", "gfa2"]:
  def to_version_s(self, shall_version):
    """
    ..note ::
      gfapy.Line subclasses do not usually redefine this method, but
      the corresponding versioned to_a method

    Returns
    -------
    str
      A string representation of self.
    """
    to_version_a = getattr(self, "to_" + shall_version + "_a")
    return gfapy.Line.SEPARATOR.join(to_version_a())

  setattr(VersionConversion, "to_" + shall_version + "_s",
          partialmethod(to_version_s, shall_version = shall_version))

  def to_version_a(self, shall_version):
    """
    .. note::
      gfapy.Line subclasses can redefine this method to convert
      between versions.

    Returns
    -------
    str list
      A list of string representations of the fields.
    """
    return self.to_list()

  setattr(VersionConversion, "to_" + shall_version + "_a",
          partialmethod(to_version_a, shall_version = shall_version))

  def to_version(self, version, shall_version):
    """
    Returns
    -------
    gfapy.Line
    	Convertion to the selected version.
    """
    v = "gfa1" if shall_version == "gfa1" else "gfa2"
    if v == version:
      return self
    else:
      to_version_a = getattr(self, "to_" + shall_version + "_a")
      return to_version_a().to_gfa_line(version = v,
                                        vlevel = self.vlevel)

  setattr(VersionConversion, "to_" + shall_version,
          partialmethod(to_version, shall_version = shall_version))
