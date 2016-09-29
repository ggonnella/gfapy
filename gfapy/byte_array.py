import gfapy
import binascii

class ByteArray(bytes):
  """
  Array of positive integers <= 255.

  Representation of the data contained in an H field.
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

  def validate():
    return True #bytes object is valid ByteArray

  @staticmethod
  def default_gfa_tag_datatype():
    """
    GFA tag datatype to use, if none is provided.

    Returns
    -------
    gfapy.Line.TagDatatype
    """
    #TODO: Implement gfapy.Line.TagDatatype
    return 'H'

  @staticmethod
  def from_string(string):
    """
    Returns a new ByteArray from a valid hex string.
    Parameters
    ----------
    string : str
      A valid hex string with even length.

    Returns
    -------
    ByteArray
      The ByteArray represented by the hex string.
    Raises
    ------
    gfapy.FormatError
      If the string has an invalid format
    gfapy.ValueError
      If the argument is not an string
    """
    if string is str:
      ByteArray(string)
    else:
      raise gfapy.ValueError
