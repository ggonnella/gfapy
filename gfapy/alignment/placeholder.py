import gfapy
from .alignment import Alignment

class AlignmentPlaceholder(gfapy.Placeholder):
  """
  A placeholder for alignment fields.
  """

  def complement(self):
    return self
