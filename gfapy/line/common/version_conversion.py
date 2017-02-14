import gfapy
try:
  from functools import partialmethod
except ImportError:
  #for compatibility with old python versions
  def partialmethod(method, **kwargs):
    return lambda self: method(self, **kwargs)

class VersionConversion:

  def to_version_s(self, version):
    """
    Returns
    -------
    str
      A string representation of self.
    """
    return gfapy.Line.SEPARATOR.join(getattr(self, "_to_"+version+"_a")())

  def _to_version_a(self, version):
    """
    .. note::
      The default is just an alias of to_list(), and ignores version.
      gfapy.Line subclasses can redefine this method to convert
      between versions.

    Returns
    -------
    str list
      A list of string representations of the fields.
    """
    return self.to_list()

  def to_version(self, version):
    """
    Returns
    -------
    gfapy.Line
    	Convertion to the selected version.
    """
    if version == self._version:
      return self
    elif version not in gfapy.VERSIONS:
      raise gfapy.VersionError("Version unknown ({})".format(version))
    else:
      return gfapy.Line.from_list(getattr(self, "_to_"+version+"_a")(),
                version=version, vlevel=self.vlevel)

for shall_version in ["gfa1", "gfa2"]:
  setattr(VersionConversion, "to_"+shall_version+"_s",
          partialmethod(VersionConversion.to_version_s,
            version = shall_version))

  setattr(VersionConversion, "_to_"+shall_version+"_a",
          partialmethod(VersionConversion._to_version_a,
            version = shall_version))

  setattr(VersionConversion, "to_"+shall_version,
          partialmethod(VersionConversion.to_version,
            version = shall_version))
