class AlignmentType:
  """
  Requirements: **alignment_type**
  """

  def is_internal(self):
    """
    Returns
    -------
    bool
      Does the line represent an internal
      overlap (GFA2 edge, not representable in GFA1)?
    """
    return self.alignment_type == "I"

  def is_containment(self):
    """
    Returns
    -------
    bool
      Does the line represent a containment
      (GFA1 containment or GFA2 edge equivalent to a GFA1 containment)?
    """
    return self.alignment_type == "C"

  def is_dovetail(self):
    """
    @return [Boolean] does the line represent a dovetail overlap?
    (GFA1 link or GFA2 edge equivalent to a GFA1 link)?
    """
    return self.alignment_type == "L"
