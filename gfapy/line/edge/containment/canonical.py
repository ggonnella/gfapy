class Canonical:

  def is_canonical(self):
    """Checks if a containment line is in the canonical form.

    As all containments (GFA1 C lines) can be specified using one of the
    two sequences in the positive orientation, only one of the possible
    variants is considered canonical by Gfapy; this allow to check if
    two C lines are equivalent to each other. In particular, the C line
    is considered canonical, if the from_orient is +.

    Note:
      An example: a containment of B (length:8) in A (length:100) at
      position 9 of A, with a cigar 1M1I2M3D4M (i.e. rpos = 19).

      ::
          A+ B+ 1M1I2M3D4M 9 == A- B- 4M3D2M1I1M 80
          A+ B- 1M1I2M3D4M 9 == A- B+ 4M3D2M1I1M 80
          A- B+ 1M1I2M3D4M 9 == A+ B- 4M3D2M1I1M 80
          A- B- 1M1I2M3D4M 9 == A+ B+ 4M3D2M1I1M 80

      Pos in the complement is equal to the length of A minus the right pos
      of B before reversing.
      We require here that A != B as A == B makes no sense for containments.
      Thus it is always possible to express the containment using a positive
      from orientation.

    Returns:
      bool
    """
    return self.from_orient() == "+"
