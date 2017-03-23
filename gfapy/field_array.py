import gfapy

class FieldArray:
  """Multiple values of the same tag in different header lines.

  Parameters:
    datatype (str): (one of `gfapy.field.Field.TAG_DATATYPE`) the datatype of
      the tags represented by the array.
    data (list, None): a list of values. The values must be compatible with the
      specified datatype. If no list is provided, the instance is initialized
      with an empty list.
  """

  def __init__(self, datatype, data = None):
    if data is None:
      self._data = []
    else:
      self._data = data
    self._datatype = datatype

  @property
  def datatype(self):
    """Datatype of the tags represented by the list.

    Returns:
      str : one of `gfapy.field.Field.TAG_DATATYPE`.
    """
    return self._datatype

  def validate(self, fieldname : str = None) -> None:
    """Datatype-specific validation on each element of the list.

    Parameters:
      fieldname (str) : optional, for error messages.
    """
    self._validate_gfa_field(None, fieldname)

  def __str__(self):
    return self._to_gfa_field(self)

  def __repr__(self):
    return "gfapy.FieldArray({},{})".format(
        repr(self._datatype),repr(self._data))

  def __eq__(self, other):
    if isinstance(other, list):
      return other == self._data
    elif isinstance(other, gfapy.FieldArray):
      return other.datatype == self._datatype and \
          other.data == self._data
    else:
      return False

  def __add__(self, other):
    if isinstance(other, list):
      self._data += other
    elif isinstance(other, gfapy.FieldArray):
      self._data += other._data

  def __iter__(self):
    return self._data.__iter__()

  def __getattr__(self, name):
    return getattr(self._data, name)

  def _validate_gfa_field(self, datatype : str, fieldname = None):
    """Datatype-specific validation.

    If no datatype is provided as parameter, the datatype of the
    array is used.
    """
    if not datatype:
      datatype = self._datatype
    for elem in self._data:
      gfapy.Field._validate_gfa_field(elem, datatype, fieldname)

  def _default_gfa_tag_datatype(self):
    """
    Default GFA tag datatype.

    Returns
    -------
    gfapy.Field::TAG_DATATYPE
    """
    return self.datatype

  def _to_gfa_field(self, datatype = None, fieldname = None):
    """Representation as tab-separated values (w/o XX:Y: prefixes)."""
    if datatype is None:
      datatype = self._datatype
    return "\t".join(
        [ gfapy.Field._to_gfa_field(x, datatype = self._datatype, \
             fieldname = fieldname) for x in self._data ])

  def _to_gfa_tag(self, fieldname, datatype = None):
    """Representation as tab-separated tags (XX:Y:VALUE)."""
    if datatype is None:
      datatype = self.datatype
    return "\t".join(
        [ gfapy.Field._to_gfa_tag(x, fieldname, datatype) \
            for x in self._data ])

  def _vpush(self, value, datatype=None, fieldname=None):
    """Add a value to the array and validate.

    Raises
    ------
    gfapy.InconsistencyError
    	If the type of the new value does not correspond to the type of
      existing values.

    Parameters
    ----------
    value : Object
    	The value to add.
    datatype : gfapy.Field.TAG_DATATYPE or None
    	The datatype to use.
      If not **None**, it will be checked that the specified datatype is the
      same as for previous elements of the field array.
      If **None**, the value will be validated, according to the datatype
      specified on field array creation.
    fieldname : str
    	The field name to use for error messages.
    """
    if datatype is None:
      gfapy.Field._validate_gfa_field(value, self.datatype, fieldname)
    elif datatype != self.datatype:
      raise gfapy.InconsistencyError(
        "Datadatatype mismatch error for field {}:\n".format(fieldname)+
        "value: {}\n".format(value)+
        "existing datatype: {};\n".format(self.datatype)+
        "new datatype: {}".format(datatype))
    self._data.append(value)

