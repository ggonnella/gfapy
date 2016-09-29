import gfapy

class AlignmentPlaceholder(gfapy.Placeholder):
  """
  A placeholder for alignment fields.
  """

  def complement(self):
    return self
