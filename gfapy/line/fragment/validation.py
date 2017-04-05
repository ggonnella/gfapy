import gfapy

class Validation:

  def validate_positions(self):
    "Checks that positions suffixed by $ are the last position of segments"
    if self.is_connected():
      seg = self.get("sid")
      seq = seg.sequence
      if not gfapy.is_placeholder(seq):
        seqlen = len(seq)
        for sfx in ["beg", "end"]:
          fn = "s_"+sfx
          pos = self.get(fn)
          if gfapy.islastpos(pos):
            if pos != seqlen:
              raise gfapy.InconsistencyError(
                  "Fragment: {}\n".format(str(self))+
                  "Field {}: $ after ".format(str(fn))+
                  "non-last position ({})\n".format(str(pos))+
                  "Segment: {}".format(str(seg)))
