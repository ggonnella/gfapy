import gfapy

class NumericArray(list):
  """
  A numeric array representable using the data type B of the GFA specification.
  """

  SIGNED_INT_SUBTYPE = ["c", "s", "i"]
  """
  Subtypes for signed integers, from the smallest to the largest
  """

  UNSIGNED_INT_SUBTYPE = [ st.upper() for st in SIGNED_INT_SUBTYPE ]
  """
  Subtypes for unsigned integers, from the smallest to the largest
  """

  INT_SUBTYPE = UNSIGNED_INT_SUBTYPE + SIGNED_INT_SUBTYPE
  """
  Subtypes for integers
  """

  FLOAT_SUBTYPE = ["f"]
  """
  Subtypes for floats
  """

  SUBTYPE = INT_SUBTYPE + FLOAT_SUBTYPE
  """
  Subtypes
  """

  SUBTYPE_BITS = {"c" : 8, "s" : 16, "i" : 32}
  """
  Number of bits of unsigned integer subtypes
  """

  SUBTYPE_RANGE = {
    "C" : (0, 2**8),
    "S" : (0, 2**16),
    "I" : (0, 2**32),
    "c" : (-(2**(8 - 1)), 2**(8 - 1)),
    "s" : (-(2**(16 - 1)), 2**(16 - 1)),
    "i" : (-(2**(32 - 1)), 2**(32 - 1))
  }
  """
  Range for integer subtypes
  (Python-style, i.e. range[1] is not included)
  """

  def validate(self):
    """
    Validate the numeric array

    Raises
    ------
    gfapy.ValueError
      If the array is not valid
    """
    self.compute_subtype()

  def compute_subtype(self):
    """
    Computes the subtype of the array from its content.

    If all elements are float, then the computed subtype is "f".
    If all elements are integer, the smallest possible numeric subtype
    is computed; thereby,
    if all elements are non-negative, an unsigned subtype is selected,
    otherwise a signed subtype.
    In all other cases an exception is raised.

    Raises
    ------
    gfapy.ValueError
      If the array is not a valid numeric array

    Returns
    -------
    one of gfapy.NumericArray.SUBTYPE
    """
    if all([ isinstance(f, float) for f in self]):
      return "f"
    else:
      e_max = None
      e_min = None
      for e in self:
        if not isinstance(e, int):
          raise gfapy.ValueError(
            "NumericArray does not contain homogenous numeric values\n"+
            "Content: {}".format(repr(self)))
        if (e_max is None or e > e_max): e_max = e
        if (e_min is None or e < e_min): e_min = e
      return gfapy.NumericArray.integer_type((e_min,e_max))

  @staticmethod
  def integer_type(range):
    """
    Computes the subtype for integers in a given range.

    If all elements are non-negative, an unsigned subtype is selected,
    otherwise a signed subtype.

    Parameters
    ----------
    range : (int, int)
      The integer range (min, max)

    Raises
    ------
    gfapy.ValueError
      If the integer range is outside all subtype ranges

    Returns
    -------
    one of gfapy.NumericArray.INT_SUBTYPE
      subtype code
    """
    if range[0] < 0:
      for st in NumericArray.SIGNED_INT_SUBTYPE:
        st_range = NumericArray.SUBTYPE_RANGE[st]
        if st_range[0] <= range[0] and st_range[1] > range[1]:
          return st
    else:
      for st in NumericArray.UNSIGNED_INT_SUBTYPE:
        st_range = NumericArray.SUBTYPE_RANGE[st]
        if st_range[1] > range[1]:
          return st
    raise gfapy.ValueError(
      "NumericArray: values are outside of all integer subtype ranges\n"+
      "Range: {}".format(repr(range)))

  def __str__(self):
    """
    GFA datatype B representation of the numeric array

    Raises
    ------
    gfapy.ValueError
      if the array is not a valid numeric array

    Returns
    -------
    str
    """
    subtype = self.compute_subtype()
    return "{},{}".format(subtype, ",".join([str(v) for v in self]))

  def _default_gfa_tag_datatype(self):
    """
    GFA tag datatype to use, if none is provided

    Returns
    -------
    one of gfapy.Field.TAG_DATATYPE
    """
    return "B"

  @classmethod
  def from_string(cls, string, valid = False):
    """
    Create a numeric array from a string

    Parameters
    ----------
    string : str
    valid : optional bool
      *(default:* **False** *)*
      If **False**, validate the range of the numeric values, according
      to the array subtype. If **True** the string is guaranteed to be valid.

    Raises
    ------
    gfapy.ValueError
      If any value is not compatible with the subtype.
    gfapy.TypeError
      If the subtype code is invalid.

    Returns
    -------
    gfapy.NumericArray
      The numeric array
    """
    if not valid:
      if len(string) == 0:
        raise gfapy.FormatError("Numeric array string shall not be empty")
      if string[-1] == ",":
        raise gfapy.FormatError("Numeric array string ends with comma\n"+
          "String: {}".format(string))
    elems = string.split(",")
    subtype = elems[0]
    if subtype not in NumericArray.SUBTYPE:
      raise gfapy.TypeError("Subtype {} unknown".format(subtype))
    if subtype != "f":
      range = NumericArray.SUBTYPE_RANGE[subtype]
    def gen():
      for e in elems[1:]:
        if subtype != "f":
          try:
            e = int(e)
          except:
            raise gfapy.ValueError("Value is not valid: {}\n".format(e)+
                "Numeric array string: {}".format(string))
          if not valid and not (e >= range[0] and e < range[1]):
            raise gfapy.ValueError((
                    "NumericArray: "+
                    "value is outside of subtype {0} range\n"+
                    "Value: {1}\n"+
                    "Range: {2}\n"+
                    "Content: {3}").format(subtype, e,
                      repr(range), repr(elems)))
          yield e
        else:
          yield float(e)
    return cls(list(gen()))
