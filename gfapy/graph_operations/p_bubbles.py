class PBubbles:

  def remove_p_bubbles(self):
    '''Removes all p-bubbles in the graph'''
    visited = set()
    for s in self.segments:
      sn = s.name
      if sn in visited:
        continue
      if s.connectivity == (1,1):
        s1 = s.neighbours_of_end("L")[0]
        s2 = s.neighbours_of_end("R")[0]
        n1 = sorted(s1.neighbours, key=lambda s:s.name)
        n2 = sorted(s2.neighbours, key=lambda s:s.name)
        for se in n1:
          visited.add(se[0].name)
        if list(n1) == [os.inverted() for os in n2]:
          self._remove_proven_p_bubble(s1, s2, n1)

  def remove_p_bubble(self, segment_end1, segment_end2,
                      count_tag=None, unit_length=None):
    '''Removes a p-bubble between segment_end1 and segment_end2'''
    if count_tag is None:
      count_tag=self.default["count_tag"]
    if unit_length is None:
      unit_length=self.default["unit_length"]
    s1 = self.try_get_segment(segment_end1.segment)
    s2 = self.try_get_segment(segment_end2.segment)
    et1 = segment_end1.end_type
    et2 = segment_end2.end_type
    n1 = sorted(s1.neighbours(et1), key=lambda s:s.name)
    n2 = sorted(s2.neighbours(et2), key=lambda s:s.name)
    assert list(n1) == [os.inverted() for os in n2]
    assert all(se[0].connectivity == (1,1) for se in n1)
    self._remove_proven_p_bubble(segment_end1, segment_end2, n1,
                           count_tag=count_tag, unit_length=unit_length)

  def _remove_proven_p_bubble(self, segment_end1, segment_end2, alternatives,
                              count_tag=None, unit_length=None):
    if count_tag is None:
      count_tag=self.default["count_tag"]
    if unit_length is None:
      unit_length=self.default["unit_length"]
    coverages = [self.try_get_segment(s[0]).coverage(count_tag=count_tag, \
                 unit_length=unit_length) for s in alternatives]
    alternatives.pop(coverages.index(max(coverages)))
    for s in alternatives:
      self.try_get_segment(s[0]).disconnect()
