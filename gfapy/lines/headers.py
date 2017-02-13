import gfapy

class Headers:
  @property
  def header(self):
    return self._records["H"]

  @property
  def headers(self):
    return self._records["H"]._split()
