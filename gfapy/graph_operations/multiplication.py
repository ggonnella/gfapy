import gfapy
import re

class Multiplication:

  def multiply(self, segment, factor, copy_names = None,
               conserve_components = True, distribute = None,
               track_origin = False, origin_tag="or", extended = False):
    """Multiply a segment by a given factor.

    The multiplication operation is implemented as described in
    Gonnella and Kurtz (2016).

    Parameters:
      segment (Line, str): the segment to multiply
      factor (int): the multiplication factor; if 0, the segment is
        deleted; if 1, nothing is done; if > 1, the multiplication
        is performed
      copy_names (list, None): an optional list of strings, the names
        of the copies which will result from the multiplication;
        the length of this list must be equal to factor - 1; if no
        list is specified, the names are computed automatically, adding
        (or incrementing) an integer as suffix to the segment name,
        until enough non-previously used names are found
      conserve_components (bool): if True, the removal of segments
        in the case where factor == 0 is only done if it does not
        split an existing connected component (thereby only dovetail
        overlaps are considered)
      extended : if True, then dovetail distribution and track origin
        are turned on by default
      distribute (str, None) : select an end for which the dovetail
        overlaps are distributed (see Gonnella and Kurtz, 2016); if ``auto``
        (the default if extended is set), an end is selected automatically,
        trying to maximize the number of links which can be deleted; if ``off``
        (the default if extended is not set), no distribution is performed; if
        ``L`` or ``R``, links of the specified end are distributed; if
        ``equal``, an end is selected (if any), for which the number of links
        is equal to the factor (if none, links are not distributed; if both,
        then ``R`` is used)
      track_origin (bool): if True, the name of the original segment (or
        the content of its own origin tag, if any) is stored
        in a tag in the copies (default: False)
      origin_tag (str): the tag where to store the origin information,
        if track_origin is set (default: ``or``)
    """
    if extended:
      if distribute == None:
        distribute = "auto"
      track_origin = True
    if factor < 0:
      raise gfapy.ArgumentError("Mulitiplication factor must be >= 0"+
          " ({} found)".format(factor))
    elif factor == 0:
      if conserve_components and factor == 1 and self.is_cut_segment(segment):
        return self
      else:
        self.rm(segment)
        return self
    elif factor == 1:
      return self
    else:
      s, sn = self._segment_and_segment_name(segment)
      if track_origin and not s.get(origin_tag):
        s.set(origin_tag, sn)
      self.__divide_segment_and_connection_counts(s, factor)
      if copy_names is None:
        copy_names = self._compute_copy_names(sn, factor)
      for cn in copy_names:
        self.__clone_segment_and_connections(s, cn)
      if distribute:
        self._distribute_links(distribute, sn, copy_names, factor)
      return self

  def _compute_copy_names(self, segment_name, factor):
    assert factor >= 2
    retval = []
    first = 2
    m = re.search(r'(.*)\*(\d+)',segment_name)
    if m:
      segment_name = m.groups()[0]
      i = int(m.groups()[1])
    offset = 0
    for i in range(first,factor+first-1):
      name = "{}*{}".format(segment_name, i+offset)
      while name in self.names:
        offset+=1
        name = "{}*{}".format(segment_name, i+offset)
      retval.append(name)
    return retval

  def __divide_counts(self, gfa_line, factor):
    for count_tag in ["KC", "RC", "FC"]:
      if count_tag in gfa_line.tagnames:
        gfa_line.set(count_tag, gfa_line.get(count_tag) // factor)

  def __divide_segment_and_connection_counts(self, segment, factor):
    self.__divide_counts(segment, factor)
    processed_circulars = set()
    for l in segment.dovetails + segment.containments:
      if l.is_circular():
        if l not in processed_circulars:
          self.__divide_counts(l, factor)
          processed_circulars.add(l)
      else:
        self.__divide_counts(l, factor)

  def __clone_segment_and_connections(self, segment, clone_name):
    cpy = segment.clone()
    cpy.name = clone_name
    cpy.connect(self)
    for l in segment.dovetails + segment.containments:
      lc = l.clone()
      if lc.from_segment == segment.name:
        lc.from_segment = clone_name
      if lc.to_segment == segment.name:
        lc.to_segment = clone_name
      lc.connect(self)

  LINKS_DISTRIBUTION_POLICY = ["off", "auto", "equal", "L", "R"]
  '''Allowed values for the links_distribution_policy option'''

  def _select_distribute_end(self, links_distribution_policy,
                             segment_name, factor):
    if links_distribution_policy not in self.LINKS_DISTRIBUTION_POLICY:
      raise gfapy.ArgumentError("Unknown links distribution policy {}\n".format(\
          links_distribution_policy)+"accepted values are: {}".format(\
          ", ".join(self.LINKS_DISTRIBUTION_POLICY)))
    if links_distribution_policy == "off":
      return None
    if links_distribution_policy in ["L", "R"]:
      return links_distribution_policy
    else:
      s = self.segment(segment_name)
      esize = len(s.dovetails_of_end("R"))
      bsize = len(s.dovetails_of_end("L"))
      return self._auto_select_distribute_end(factor, bsize, esize,
                                       links_distribution_policy == "equal")

  # (keep separate for testing)
  # @tested_in unit_multiplication
  @staticmethod
  def _auto_select_distribute_end(factor, bsize, esize, equal_only):
    if esize == factor:
      return "R"
    elif bsize == factor:
      return "L"
    elif equal_only:
      return None
    elif esize < 2:
      if bsize < 2:
        return None
      else:
        return "L"
    elif bsize < 2:
      return "R"
    elif esize < factor:
      if bsize <= esize:
        return "R"
      elif bsize < factor:
        return "L"
      else:
        return "R"
    elif bsize < factor:
      return "L"
    elif bsize <= esize:
      return "L"
    else:
      return "R"

  def _distribute_links(self, links_distribution_policy, segment_name,
                        copy_names, factor):
    if factor < 2:
      return
    end_type = self._select_distribute_end(links_distribution_policy,
                                           segment_name, factor)
    if end_type is None:
      return
    et_links = self.segment(segment_name).dovetails_of_end(end_type)
    diff = max([len(et_links)-factor, 0])
    links_signatures = list([repr(l.other_end(gfapy.SegmentEnd(segment_name, \
                          end_type))) for l in et_links])
    for i, sn in enumerate([segment_name]+copy_names):
      to_keep = links_signatures[i:i+diff+1]
      links = self.segment(sn).dovetails_of_end(end_type).copy()
      for l in links:
        l_sig = repr(l.other_end(gfapy.SegmentEnd(sn, end_type)))
        if l_sig not in to_keep:
          l.disconnect()

  def _segment_and_segment_name(self, segment_or_segment_name):
    if isinstance(segment_or_segment_name, gfapy.Line):
      s = segment_or_segment_name
      sn = segment_or_segment_name.name
    else:
      s = self.segment(segment_or_segment_name)
      sn = segment_or_segment_name
    return s, sn
