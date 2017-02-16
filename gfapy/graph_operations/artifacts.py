import gfapy

class Artifacts:

  def remove_small_components(self, minlen):
    for cc in filter(lambda c: sum([self.segment(sn).length for sn in c]) < minlen,
                     self.connected_components()):
      for s in cc:
        self.rm(s)

  def remove_dead_ends(self, minlen):
    for s in self.segments:
      c = s._connectivity()
      if s.length < minlen and \
        (c[0]==0 or c[1]==0) and \
          not self.is_cut_segment(s):
        self.rm(s)
