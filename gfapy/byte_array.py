import gfapy
import binascii

class ByteArray(bytes):
  """Array of unsigned byte values.

  The class is used for the representation of the data contained in H tags.
  The content of instances of the class is read-only. To edit the array,
  the instance must be cast to a list, edited, and casted back to ByteArray,
  as in the example below.

  Example:
    >>> import gfapy
    >>> a = gfapy.ByteArray([1,2,3])
    >>> a[0] = 0
    Traceback (most recent call last):
    ...
    TypeError: 'ByteArray' object does not support item assignment
    >>> a_lst = list(a)
    >>> a_lst[0] = 0
    >>> a = gfapy.ByteArray(a_lst)
    >>> str(a)
    '000203'

  Parameters:
    arg (string or bytes): If the argument is of type string,
        it has to be a valid hex string.

  Raises:
    gfapy.FormatError: If the argument is a string and has an invalid format.
    gfapy.ValueError: If the argument is not an string or a byte array.
  """

  def __new__(cls, arg):
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
    return str(binascii.hexlify(self), "utf8").upper()

  def validate(self):
    """Validates the content of the instance.

    The content is always valid, as values cannot be modified directly (see
    below) and trying to create from invalid data will raise an exception. So
    the validation method is only a placeholder which always does nothing.
    """
    pass

  def _default_gfa_tag_datatype(self):
    """GFA tag datatype to use by default"""
    return 'H'
