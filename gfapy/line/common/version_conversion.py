import gfapy
try:
  from functools import partialmethod
except ImportError:
  #for compatibility with old python versions
  def partialmethod(method, **kwargs):
    return lambda self: method(self, **kwargs)

class VersionConversion:

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
  def dialect(self):
    """
    Returns
    -------
    gfapy.DIALECTS, None
      GFA specification version
    """
    return self._dialect

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
      The default is an alias of to_list() if version is equal to the
      version of the line, and an empty list otherwise.
      gfapy.Line subclasses can redefine this method to convert
      between versions.

    Returns
    -------
    str list
      A list of string representations of the fields.
    """
    if version == self._version:
      return self.to_list()
    else:
      return []

  def to_version(self, version, raise_on_failure=True):
    """
    Returns
    -------
    gfapy.Line
    	Conversion to the selected version.
    """
    if version == self._version:
      return self
    elif version not in gfapy.VERSIONS:
      raise gfapy.VersionError("Version unknown ({})".format(version))
    else:
      l = getattr(self, "_to_"+version+"_a")()
      if l:
        try:
          converted = gfapy.Line(l, version=version, vlevel=self.vlevel)
        except:
          raise gfapy.RuntimeError("Conversion to {} failed\n".format(version)+
              "Line: {}".format(str(self)))
        return converted
      elif raise_on_failure:
        raise gfapy.VersionError("Records of type {} ".format(self.record_type)+
            "cannot be converted from version {} ".format(self._version)+
            "to version {}".format(version))
      else:
        return None

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
