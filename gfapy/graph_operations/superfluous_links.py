import gfapy

class SuperfluousLinks:

  def enforce_segment_mandatory_links(self, segment, conserve_components=True):
    """Enforce mandatory dovetails overlaps of a given segment to other
    segments, by removing all other dovetail overlaps between those segments.

    The definition of mandatory links follows the one
    given in Gonnella and Kurtz, 2016.

    Parameters:
      segment (Line, str) : the segment
      conserve_components (bool): if True, then dovetail overlaps are only
        removed, if their removal does not split connected components
        of the graph (considering as connections only dovetail overlaps)
    """
    s, sn = self._segment_and_segment_name(segment)
    se = {}; l = {}
    for et in ["L", "R"]:
      se[et] = [sn, et]
      l[et] = segment(s).dovetails_of_end(et)
    if len(l["L"])==1 and len(l["R"])==1:
      oe = {}
      for et in ["L", "R"]:
        oe[et] = l[et][0].other_end(se[et])
      if oe["L"] == oe["R"]:
        return
      for et in ["L", "R"]:
        self._delete_other_links(oe[et], se[et],
                                conserve_components=conserve_components)
    else:
      if l["L"].size == 1:
        et = "L"
      elif l["R"].size == 1:
        et = "R"
      else:
        return
      oe = l[et][0].other_end(se[et])
      self._delete_other_links(oe, se[et],
                              conserve_components=conserve_components)

  def enforce_all_mandatory_links(self, conserve_components=True):
    """Enforce mandatory dovetails between pairs of segments, by removing all
       other dovetail overlaps between those segments.

    The definition of mandatory links follows the one
    given in Gonnella and Kurtz, 2016.

    Parameters:
      conserve_components (bool): if True, then dovetail overlaps are only
        removed, if their removal does not split connected components
        of the graph (considering as connections only dovetail overlaps)
    """
    for sn in self.segment_names:
      self.enforce_segment_mandatory_links(sn, conserve_components=
                                               conserve_components)

  def remove_self_link(self, segment):
    """Remove self links of a segment, if any.

    Remove any dovetail overlap of a segment to itself.

    Parameters:
      segment (str, Line): the segment
    """
    if not isinstance(segment, gfapy.Line):
      segment = self.try_get_segment(segment)
    for e in segment.dovetails:
      if e.from_segment == e.to_segment:
        e.disconnect()

  def remove_self_links(self):
    """Remove all dovetail overlap of segments to themselves, if any."""
    for sn in self.segment_names:
      self.remove_self_link(sn)
