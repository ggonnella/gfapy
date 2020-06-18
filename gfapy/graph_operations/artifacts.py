class Artifacts:

  def remove_small_components(self, minlen):
    """Remove connected components with combined segment length < minlen.

    Note:
      Connected components of the graph are computed, considering only dovetail
      overlaps as connection of segments.

    Parameters:
      minlen (int) : the minimal length of the components to keep.
    """
    for cc in filter(lambda c: sum([self.segment(sn).length for sn in c]) \
                     < minlen, self.connected_components()):
      for s in cc:
        self.rm(s)

  def remove_dead_ends(self, minlen):
    """Remove dead end segments from the graph.

    Dead end segments are defined as segment, with a sequence smaller
    than a given minlen parameter, and whose removal does not split
    connected components in the graph, and which have no connections (dovetail
    overlaps) for at least one of the two ends of the sequence.

    Note:
      Only dovetail overlaps are considered as connections.

    Parameters:
      minlen (int) : the minimal length of an end to keep.
    """
    for s in self.segments:
      c = s._connectivity()
      if s.length < minlen and \
        (c[0]==0 or c[1]==0) and \
          not self.is_cut_segment(s):
        self.rm(s)
