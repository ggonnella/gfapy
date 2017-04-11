import gfapy

class Pos:

  @property
  def rpos(self):
    """The rightmost coordinate of the contained sequence in the container.

    Returns:
      int : 0-based coordinate

    Raises:
      gfapy.ValueError : If the overlap is a placeholder, thus the computation
        cannot be performed.
    """
    if isinstance(self.overlap, gfapy.Placeholder):
      raise gfapy.ValueError("The overlap is a placeholder, therefore"+
          "rpos cannot be computed")
    return self.pos + self.overlap.length_on_reference()
