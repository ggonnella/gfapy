import gfapy
import binascii

class ByteArray(bytes):
  """
  Array of positive integers <= 255.

  Representation of the data contained in a H field.

  Validation
  ----------
  Differently from the Ruby version of this class, the content
  is always valid, as values cannot be modified directly (see below)
  and trying to create from invalid data will raise an exception.
  So the validation method is only a placeholder which always
  returns True.

  Editing the array
  -----------------
  The content of the class is read-only. To edit the array, you must
  cast the object to a list, edit it, and cast it back, e.g.:
  a = gfapy.ByteArray([1,2,3])
  # a[0] = 0 would not work!
  a_lst = list(a)
  a_lst[0] = 0
  a = gfapy.ByteArray(a_lst)
  str(a) # => "000203"
  """

  def __new__(cls, arg):
    """
    Creates a new ByteArray.

    Parameters
    ----------
    arg : string or bytes
      If the argument is of type string, it has to be a valid hex string.

    Raises
    ------
    gfapy.FormatError
      If the argument is a string and has an invalid format.
    gfapy.ValueError
      If the argument is not an string or an byte array.
    """
    try:
      if isinstance(arg, str):
        if len(arg) == 0:
          raise gfapy.FormatError
        return bytes.__new__(cls, binascii.unhexlify(arg))
      else:
        return bytes.__new__(cls, arg)
    except binascii.Error:
      raise gfapy.FormatError
    except ValueError:
      raise gfapy.ValueError
    except TypeError:
      raise gfapy.ValueError

  def __str__(self):
    """
    Hex string representation of the byte array.

    Returns
    -------
    str
      Hex string representation of the byte array.
    """
    return str(binascii.hexlify(self), "utf8").upper()

  def validate(self):
    return True #bytes object is valid ByteArray

  def _default_gfa_tag_datatype(self):
    """
    GFA tag datatype to use, if none is provided.
    """
    return 'H'
