import gfapy

class Placeholder:
  """
  A placeholder is used in mandatory fields when a value is not specified.

  Its string representation is an asterix ``*``.
  """

  def __str__(self):
    return "*"

  def __repr__(self):
    return "gfapy.Placeholder()"

  def __bool__(self):
    return False

  def complement(self):
    return self

  def is_empty(self):
    """
    A placeholder is always empty.

    Returns
    -------
    True : bool
      Returns always **True**
    """
    return True

  def validate(self, *args, **keyargs):
    """
    A placeholder is always valid.
    """
    return None

  def rc(self):
    """
    For compatibility with String#rc (gfapy.sequence module).

    Returns
    -------
    self : Placeholder
    """
    return self

  def __len__(self):
    """
    Length/size of a placeholder is always 0.

    Returns
    -------
    0 : int
      Returns always 0
    """
    return 0

  def __getitem__(self, key):
    """
    Any cut of the placeholder returns the placeholder itself.

    Parameters
    ----------
    key
      Ignored

    Returns
    -------
    self : Placeholder
    """
    return self

  def __add__(self, other):
    """
    Adding the placeholder to anything returns the placeholder itself.

    Parameters
    ----------
    other
      Ignored

    Returns
    -------
    self : Placeholder
    """
    return self

  def __eq__(self, other):
    return gfapy.is_placeholder(other)

def is_placeholder(object):
  if object is Placeholder:
    return True
  elif object is None:
    return True
  elif object == "*":
    return True
  elif isinstance(object, list) and len(object) == 0:
    return True
  else:
    return False
