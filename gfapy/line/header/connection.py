import gfapy

class Connection:

  def connect(self, gfa):
    if gfa.header is not self:
      raise gfapy.RuntimeError(
        "gfapy.line.Header instances cannot be connected\n"+
        "Use gfa.add_line(this_line) to add the information\n"+
        "contained in this header line to the header of a GFA instance.")
    else:
      self._gfa = gfa
