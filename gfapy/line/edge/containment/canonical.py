class Canonical:

  def is_canonical(self):
    #TODO: check docstring
    """
    Returns **True** if the containment is canonical, **False** otherwise.

    == Definition of canonical containment

    A containment is canonical if the from orientation is +

    === Details

    Each containment has an equivalent complement containment.
    Consider a containment of B (length:8) in A (length:100) at position 9 of A
    with a cigar 1M1I2M3D4M (i.e. rpos = 19).

    A+ B+ 1M1I2M3D4M 9 == A- B- 4M3D2M1I1M 80
    A+ B- 1M1I2M3D4M 9 == A- B+ 4M3D2M1I1M 80
    A- B+ 1M1I2M3D4M 9 == A+ B- 4M3D2M1I1M 80
    A- B- 1M1I2M3D4M 9 == A+ B+ 4M3D2M1I1M 80

    Pos in the complement is equal to the length of A minus the right pos
    of B before reversing.

    We require here that A != B as A == B makes no sense for containments.
    Thus it is always possible to express the containment using a positive
    from orientation.

    For this reason the canon is simply defined as + from orientation.

    Returns
    -------
    bool
    """
    return self.from_orient() == "+"
