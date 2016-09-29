import gfapy

class Placeholder:
  """
  A placeholder is used in mandatory fields when a value is not specified.

  Its string representation is an asterix ``*``.
  """

  def __str__(self):
    return "*"

  def to_alignment(self, allow_traces = True):
    """
    For compatibility with the to_alignment method of other classes
    (CIGAR, Trace).

    Parameters
    ----------
    allow_traces : bool, optional
      Ignored

    Returns
    -------
    self : Placeholder
    """
    return self

  def to_cigar(self):
    """
    For compatibility with the to_cigar method of other classes.

    Returns
    -------
    self : Placeholder
    """
    return self

  def empty(self):
    """
    A placeholder is always empty.

    Returns
    -------
    True : bool
      Returns always **True**
    """
    return True

  def validate(self):
    """
    A placeholder is always valid.
    """

  def rc(self):
    """
    For compatibility with String#rc (gfapy.sequence module).

    Returns
    -------
    self : Placeholder
    """
    return self

  def length(self):
    """
    Length/size of a placeholder is always 0.

    Returns
    -------
    0 : int
      Returns always 0
    """
    return 0

  __len__ = length

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
    return (other is Placeholder) or (other == "*")

  def is_placeholder(object):
    if object is Placeholder:
      return True
    elif object == "*":
      return True
    elif isinstance(object, list) and object.size == 0:
      return True
    else:
      return False
