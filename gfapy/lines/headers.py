import gfapy

class Headers:
  def header(self):
    return self._records["H"]

  def headers(self):
    return self._records["H"].split()
