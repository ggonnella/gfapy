class Headers:
  @property
  def header(self):
    """The header of the Gfa instance.

    For simplicity of access, all tags are summarized in a single
    Header instance. If the same tag is defined on different H lines,
    the values are collected into a FieldArray instance.
    """
    return self._records["H"]

  @property
  def headers(self):
    """The splitted header of the Gfa instance.

    The header of the Gfa instance, splitted into H lines containing
    each a single tag.
    """
    return self._records["H"]._split()
