from itertools import groupby
import gfapy

class InvertibleSegments:

  def randomly_orient_invertibles(self):
    ''' Selects a random orientation for all invertible segments.

    For the definition of invertible segment, see Gonnella and Kurtz (2016).'''
    for sn in self.segment_names:
      if self._segment_same_links_both_ends(sn):
        self._randomly_orient_proven_invertible_segment(sn)

  def randomly_orient_invertible(self, segment):
    '''Selects a random orientation for an invertible segment.

    For the definition of invertible segment, see Gonnella and Kurtz (2016).'''
    if isinstance(segment, gfapy.Line):
      segment_name = segment.name
    else:
      segment_name = segment
    if not self._segment_same_links_both_ends(segment_name):
      raise gfapy.RuntimeError("Only segments with links to the same or "+
          "equivalent segments at both ends can be randomly oriented")
    self._randomly_orient_proven_invertible_segment(segment_name)

  def _randomly_orient_proven_invertible_segment(self, segment_name):
    se = gfapy.SegmentEnd([segment_name, "R"])
    parts = self._partitioned_links_of(se)
    if len(parts) == 2:
      tokeep1_other_end = parts[0][0].other_end(se)
      tokeep2_other_end = parts[1][0].other_end(se)
    elif len(parts) == 1 and len(parts[0]) == 2:
      tokeep1_other_end = parts[0][0].other_end(se)
      tokeep2_other_end = parts[0][1].other_end(se)
    else:
      return
    if len(tokeep1_other_end.segment.dovetails(
          tokeep1_other_end.end_type)) < 2:
      return
    if len(tokeep2_other_end.segment.dovetails(
          tokeep2_other_end.end_type)) < 2:
      return
    self._delete_other_links(se, tokeep1_other_end)
    self._delete_other_links(se.inverted(), tokeep2_other_end)
    self._annotate_random_orientation(segment_name)

  def _link_targets_for_cmp(segment_end):
    return ["".join(str(l.other_end(segment_end))) \
            for l in segment_end.segment.dovetails(segment_end.end_type)]

  def _segment_same_links_both_ends(self, segment_name):
    e_links = self._link_targets_for_cmp(gfapy.SegmentEnd(segment_name, "R"))
    b_links = self._link_targets_for_cmp(gfapy.SegmentEnd(segment_name, "L"))
    return e_links == b_links

  def _segment_signature(self, segment_end):
    s = self.try_get_segment(segment_end.segment)
    return ",".join(self._link_targets_for_cmp(segment_end))+"\t"+\
           ",".join(self._link_targets_for_cmp(segment_end.inverted()))+"\t"+\
           s.field_to_s("or")

  def _partitioned_links_of(self, segment_end):
    links = segment_end.segment.dovetails(segment_end.end_type)
    sigs = {}
    for l in links:
      sigs[id(l)] = self._segment_signature(l.other_end(segment_end))
    sig = lambda l: sigs[id(l)]
    return [list(v) for k,v in groupby(sorted(links,key=sig),key=sig)]

  def _annotate_random_orientation(self, segment_name):
    segment = self.try_get_segment(segment_name)
    n = segment.name.split("_")
    pairs = 0
    pos = [1, segment.LN]
    if segment.get("or"):
      o = segment.field_to_s("or").split(",")
      if len(o) > 2:
        while o[-1]=="{}^".format(o[0]) or o[0]=="{}^".format(o[-1]):
          pairs += 1
          o.pop()
          o.pop(0)
      if segment.mp:
        pos = [segment.mp[pairs*2], segment.mp[-1-pairs*2]]
    rn = segment.rn
    if rn is None:
      rn = []
    rn += pos
    segment.rn = rn
    n[pairs] = "({}".format(n[pairs])
    n[-1-pairs] = "{})".format(n[-1-pairs])
    self.rename(segment.name, "_".join(n))
