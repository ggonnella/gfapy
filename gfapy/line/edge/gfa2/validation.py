import gfapy

class Validation:

  def validate_positions(self):
    "Checks that positions suffixed by $ are the last position of segments"
    if self.is_connected():
      for n in ["1","2"]:
        seg = self.get("sid"+n).line
        seq = seg.sequence
        if not gfapy.is_placeholder(seq):
          seqlen = len(seq)
          for pfx in ["beg", "end"]:
            fn = pfx+n
            pos = self.get(fn)
            if gfapy.islastpos(pos):
              if pos != seqlen:
                raise gfapy.InconsistencyError(
                    "Edge: {}\n".format(str(self))+
                    "Field {}: $ after ".format(fn)+
                    "non-last position {}\n".format(str(pos))+
                    "Segment: {}".format(str(seg)))
