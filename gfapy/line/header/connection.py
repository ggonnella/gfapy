class Connection:

  def connect(self, gfa):
    raise gfapy.RuntimeError(
      "gfapy.line.Header instances cannot be connected\n"+
      "Use GFA.header.merge(this_line) to add the information\n"+
      "contained in this header line to the header of a GFA instance.")
