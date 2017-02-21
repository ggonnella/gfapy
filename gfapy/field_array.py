import gfapy

# GG: the class contains a number of api private methods, maybe we should add a _ before their name

class FieldArray:
  """
  Array representing multiple values of the same tag in different header lines.
  """
  @property
  def datatype(self):
    return self._datatype

  def __init__(self, datatype, data = None):
    """
    Parameters
    ----------
    datatype: gfapy.Field.TAG_DATATYPE
    	The datatype to use.
    """
    if data is None:
      self._data = []
    else:
      self._data = data
    self._datatype = datatype

  def __repr__(self):
    return "gfa.FieldArray({},{})".format(repr(self._datatype),repr(self._data))

  def validate(self, fieldname : str = None) -> None:
    """
    Run the datatype-specific validation on each element of the array.

    Parameters
    ----------
    fieldname
      Fieldname to use for error messages.
    """
    self._validate_gfa_field(None, fieldname)

  def _validate_gfa_field(self, datatype : str, fieldname=None):
    """
    Run a datatype-specific validation on each element of the array,
    using the specified datatype.

    Parameters
    ----------
    datatype : gfapy.Field.TAG_DATATYPE or None
     	Datatype to use for the validation. 
      Use None to use the stored datatype (self.datatype)
    fieldname : str
    	Fieldname to use for error messages.
    """
    if not datatype:
      datatype = self._datatype
    for elem in self._data:
      gfapy.Field.validate_gfa_field(elem, datatype, fieldname)

  def _default_gfa_tag_datatype(self):
    """
    Default GFA tag datatype.

    Returns
    -------
    gfapy.Field::TAG_DATATYPE
    """
    return self.datatype

  def __str__(self):
    return self._to_gfa_field(self)

  def _to_gfa_field(self, datatype = None, fieldname = None):
    """
    String representation of the field array.

    Parameters
    ----------
    datatype : gfapy.Field.TAG_DATATYPE
    	*(defaults to: ***self.datatype***)* datatype of the data
    fieldname : str
    	*(defaults to ***None***)* fieldname to use for error messages

    Returns
    -------
    str
    	Tab-separated string representations of the elements.
    """
    if datatype is None:
      datatype = self._datatype
    return "\t".join(
        [ gfapy.Field.to_gfa_field(x, datatype = self._datatype, \
             fieldname = fieldname) for x in self._data ])

  def _to_gfa_tag(self, fieldname, datatype = None):
    """
    String representation of the field array as GFA tags.

    Parameters
    ----------
    datatype : gfapy.Field.TAG_DATATYPE
      *(defaults to: ***self.datatype***)* datatype of the data
    fieldname : str
    	Name of the tag

    Returns
    -------
    str
    	Tab-separated GFA tag representations of the elements.
    """
    if datatype is None:
      datatype = self.datatype
    return "\t".join(
        [ gfapy.Field.to_gfa_tag(x, fieldname, datatype) \
            for x in self._data ])

  def _vpush(self, value, datatype=None, fieldname=None):
    """
    Add a value to the array and validate.

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
      gfapy.Field.validate_gfa_field(value, self.datatype, fieldname)
    elif datatype != self.datatype:
      raise gfapy.InconsistencyError(
        "Datadatatype mismatch error for field {}:\n".format(fieldname)+
        "value: {}\n".format(value)+
        "existing datatype: {};\n".format(self.datatype)+
        "new datatype: {}".format(datatype))
    self._data.append(value)

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

