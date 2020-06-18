import gfapy

class AlignmentPlaceholder(gfapy.Placeholder):
  """
  A placeholder subclass for alignment fields.

  Instances are usually created from their string representations, using the
  :class:`~gfapy.alignment.alignment.Alignment` factory class constructor.
  """

  def complement(self):
    """For compatibility with CIGAR alignments
    Returns:
      AlignmentPlaceholder : self
    """
    return self

  def __repr__(self):
    return "gfapy.AlignmentPlaceholder()"
