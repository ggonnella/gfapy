import gfapy

class LinearPaths:

  def linear_path(self, segment, exclude = None):
    if isinstance(segment, gfapy.Line):
      segment_name = segment.name
    else:
      segment_name = segment
      segment = self.segment(segment_name)
    cs = segment._connectivity()
    if exclude is None:
      exclude = set()
    segpath = gfapy.SegmentEndsPath()
    for i, et in enumerate(["L", "R"]):
      if cs[i] == 1:
        exclude.add(segment_name)
        if len(segpath) > 0:
          segpath.pop()
        segpath += self.__traverse_linear_path(
            gfapy.SegmentEnd(segment, et), exclude)
    return segpath

  def linear_paths(self, redundant = False):
    exclude = set()
    if redundant:
      junction_exclude = set()
    retval = []
    segnames = self.segment_names
    if self._progress:
      self.__progress_log_init("linear_paths", "segments", len(segnames),
          "Detect linear paths ({})".format(len(segnames)))
    for sn in segnames:
      if self._progress:
        self.__progress_log("linear_paths")
      if sn in exclude:
        next
      lp = self.linear_path(sn, exclude)
      if not redundant:
        if len(lp) > 1:
          retval.append(lp)
      else:
        if lp:
          self.__extend_linear_path_to_junctions(lp)
          retval.append(lp)
        else:
          retval += self.__junction_junction_paths(sn, junction_exclude)
    if self._progress:
      self.__progress_log_end("linear_paths")
    return retval

  def merge_linear_path(self, segpath, **options):
    if len(segpath) < 2:
      return self
    if options.get("redundant",False) and (segpath[0] in [True, False]):
      first_redundant = segpath.pop(0)
      last_redundant = segpath.pop()
    else:
      first_redundant = False
      last_redundant = False
    segpath = [gfapy.SegmentEnd(s) for s in segpath]
    merged, first_reversed, last_reversed = \
        self.__create_merged_segment(segpath, options)
    self.append(merged)
    if first_redundant:
      self.__link_duplicated_first(merged, self.segment(segpath[0].segment), \
                                   first_reversed, options["jntag"])
    else:
      self.__link_merged(merged.name, segpath[0].inverted(), first_reversed)
    if last_redundant:
      self.__link_duplicated_last(merged, self.segment(segpath[-1].segment), \
                                  last_reversed, options["jntag"])
    else:
      self.__link_merged(merged.name, segpath[-1], last_reversed)
    idx1 = 1 if first_redundant else 0
    idx2 = -1 if last_redundant else None
    for sn_et in segpath[idx1:idx2]:
      self.segment(sn_et.segment).disconnect()
      if self._progress:
        self.__progress_log("merge_linear_paths", 0.05)
    return self

  def merge_linear_paths(self, **options):
    paths = self.linear_paths(options.get("redundant",False))
    if self._progress:
      psize = sum([len(path) for path in paths]) // 2
      self.__progress_log_init("merge_linear_paths", "segments", psize,
          "Merge {} linear paths ".format(len(paths))+
          "({} segments)".format(psize))
    for path in paths:
      self.merge_linear_path(path, options=options)
    if self._progress:
      self.__progress_log_end("merge_linear_paths")
    if options.get("redundant",False):
      self.__remove_junctions(options["jntag"])
    return self

  def __traverse_linear_path(self, segment_end, exclude):
    lst = gfapy.SegmentEndsPath()
    current = gfapy.SegmentEnd(segment_end)
    current.segment = self.segment(current.segment)
    while True:
      after = current.segment.dovetails_of_end(current.end_type)
      before = current.segment.dovetails_of_end(gfapy.invert(current.end_type))
      if (len(before) == 1 and len(after) == 1) or not lst:
        lst.append(gfapy.SegmentEnd(current.name, current.end_type))
        exclude.add(current.name)
        current = after[0].other_end(current).inverted()
        if current.name in exclude:
          break
      elif len(before) == 1:
        lst.append(gfapy.SegmentEnd(current.name, current.end_type))
        exclude.add(current.name)
        break
      else:
        break
    if segment_end.end_type == "L":
      return list(reversed(lst))
    else:
      return lst

  def __sum_of_counts(self, segpath, multfactor = 1):
    retval = {}
    segs = [self.try_get_segment(sn_et.segment) for sn_et in segpath]
    for count_tag in ["KC","RC","FC"]:
      for s in segs:
        if count_tag in s.tagnames:
          if count_tag not in retval:
            retval[count_tag] = 0
          retval[count_tag] += int(retval[count_tag]*multfactor)
    return retval

  @staticmethod
  def __reverse_segment_name(name, separator):
    retval = []
    for part in name.split(separator):
      has_openp = (part[0] == "(")
      has_closep = (part[-1] == ")")
      if has_openp:
        part = part[1:]
      if has_closep:
        part = part[:-1]
      if part[-1] == "^":
        part = part[:-1]
      else:
        part = part + "^"
      if has_openp:
        part += ")"
      if has_closep:
        part = "(" + part
      retval.append(part)
    return separator.join(reverse(retval))

  @staticmethod
  def __reverse_pos_array(pos_array, lastpos):
    if pos_array is None:
      return None
    if lastpos is None:
      return None
    return list(reverse([lastpos - pos + 1 for pos in pos_array]))

  @staticmethod
  def __add_segment_to_merged(merged, segment, is_reversed, cut, init,
                              options):
    if is_reversed:
      s = gfapy.sequence.rc(segment.sequence)[cut:]
    else:
      s = segment.sequence[cut:]
    if init:
      merged.sequence = s
      if options.get("merged_name",None):
        merged.name = options["merged_name"]
      else:
        merged.name = segment.name
      merged.LN = segment.LN
    else:
      if gfapy.is_placeholder(segment.sequence):
        merged.sequence = gfapy.Placeholder()
      else:
        merged.sequence += s
      if not options.get("merged_name",None):
        merged.name += "_"
        merged.name += segment.name
      if merged.LN:
        if segment.LN:
          merged.LN += (segment.LN - cut)
        else:
          merged.LN = None

  def __get_short_merged_name(self, options):
    forbidden = self.names
    i = 1
    options["merged_name"] = "merged1"
    while options["merged_name"] in forbidden:
      i += 1
      options["merged_name"] = "merged{}".format(i)

  def __create_merged_segment(self,segpath, options):
    merged = self.try_get_segment(segpath[0].segment).clone()
    jntag = options["jntag"] if "jntag" in options else "jn"
    merged.set(jntag, None)
    total_cut = 0
    a = segpath[0]
    first_reversed = (a.end_type == "L")
    last_reversed = None
    if options.get("merged_name",None) == "short":
      self.__get_short_merged_name(self, options)
    self.__add_segment_to_merged(merged, self.segment(a.segment),
        first_reversed, 0, True, options)
    if self._progress:
      self.__progress_log("merge_linear_paths", 0.95)
    for i in range(len(segpath)-1):
      b = gfapy.SegmentEnd(segpath[i+1]).inverted()
      ls = self.segment(a.segment).end_relations(a.end_type, b, "dovetails")
      if len(ls) != 1:
        msg = "A single link was expected between {}".format(a) + \
              "and {}".format(b) + "{} were found".format(len(ls))
        raise gfapy.ValueError(msg)
      l = ls[0]
      if not l.overlap:
        cut = 0
      elif all(op.code in ["M","="] for op in l.overlap):
        cut = sum([len(op) for op in l.overlap])
      else:
        raise gfapy.ValueError(
            "Merging is only allowed if all operations are M/=")
      total_cut += cut
      last_reversed = (b.end_type == "R")
      self.__add_segment_to_merged(merged, self.segment(b.segment),
          last_reversed, cut, False, options)
      a = gfapy.SegmentEnd(b).inverted()
      if self._progress:
        self.__progress_log("merge_linear_paths", 0.95)
    if not gfapy.is_placeholder(merged.sequence):
      if self._version == "gfa1":
        if not merged.LN:
          merged.LN = len(merged.sequence)
        elif self._vlevel > 0 and merged.LN != len(merged.sequence):
          raise gfapy.InconsistencyError(
              "Computed sequence length {} ".format(merged.sequence.length)+
              "and computed LN {} differ".format(merged.LN))
    if merged.length is not None:
      for count_tag in ["KC", "RC", "FC"]:
        merged.set(count_tag, None)
    else:
      factor = 1
      if options["cut_counts"]:
        factor = merged.length / (total_cut+merged.length)
      for count_tag,count in __sum_of_counts(segpath,factor).items():
        merged.set(count_tag, count)
    return merged, first_reversed, last_reversed

  def __link_merged(self, merged_name, segment_end, is_reversed):
    for l in self.segment(segment_end.segment).dovetails_of_end(
                                                 segment_end.end_type):
      l2 = l.clone()
      if l2.to == segment_end.segment:
        l2.to = merged_name
        if is_reversed:
          l2.to_orient = gfapy.invert(l2.to_orient)
      else:
        l2.frm = merged_name
        if is_reversed:
          l2.from_orient = gfapy.invert(l2.from_orient)
      self.add_line(l2)

