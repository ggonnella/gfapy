class AlignmentType:

  def is_internal(self):
    """Does the edge represent an internal alignment?

    Note:
      only GFA2 E lines may represent internal alignments

    Returns:
      bool
    """
    return self._alignment_type == "I"

  def is_containment(self):
    """Does the edge represent a containment?

    Note:
      A containment is either a C line (GFA1) or an E line, for which the
      coordinates of at least one of the two sequences go from 0 to the end of
      the sequence (GFA2).

    Returns:
      bool
    """
    return self._alignment_type == "C"

  def is_dovetail(self):
    """Does the edge represent a dovetail overlap?

    Note:
      A dovetail is either a L line (GFA1) or an E line (GFA2), for which the
      coordinates of both sequences go from the beginning of the sequence
      to some internal position, or from some internal position to the end of
      the sequence.

    Returns:
      bool
    """
    return self._alignment_type == "L"
