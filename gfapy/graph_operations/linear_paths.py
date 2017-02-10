import gfapy

class LinearPaths:

  def linear_path(self, segment, exclude = None):
    if exclude == None:
      exclude = set()
    s = segment.name
    segpath = gfapy.SegmentEndsPath()
    for i, et in enumerate("L", "R"):
      if cs[i] == 1:
        exclude.append(s)
        segpath.pop()
        segpath += self.__traverse_linear_path(gfapy.SegmentEnd(s, et), exclude)
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
    if options["redundant"] and (segpath[0] in [True, False]):
      first_redundant = segpath.pop(0)
      last_redundant = segpath.pop()
    else:
      first_redundant = False
      last_redundant = False
    segpath = [s.to_segment_end() for s in segpath]
    merged, first_reversed, last_reversed = \
        self.__create_merged_segment(segpath, options)
    self.append(merged)
    if first_redundant:
      self.__link_duplicated_first(merged, self.segment(segpath[0].segment), \
                                   first_reversed, options["jntag"])
    else:
      self.__link_merged(merged.name, segpath[0].invert(), first_reversed)
    if last_redundant:
      self.__link_duplicated_last(merged, self.segment(segpath[-1].segment), \
                                  last_reversed, options["jntag"])
    else:
      self.__link_merged(merged.name, segpath[-1], last_reversed)
    idx1 = 1 if first_redundant else 0
    idx2 = -1 if last_redundant else None
    for sn_et in segpath[idx1:idx2]:
      self.segment(sn_et.segment).disconnect
      if self._progress:
        self.__progress_log("merge_linear_paths", 0.05)
    return self

  def merge_linear_paths(self, **options):
    paths = self.linear_paths(options["redundant"])
    if self._progress:
      psize = sum([len(path) for path in paths]) // 2
      self.__progress_log_init("merge_linear_paths", "segments", psize,
          "Merge {} linear paths ".format(len(paths))+
          "({} segments)".format(psize))
    for path in paths:
      self.merge_linear_path(path, options=options)
    if self._progress:
      self.__progress_log_end("merge_linear_paths")
    if options["redundant"]:
      self.__remove_junctions(options["jntag"])
    return self

  def __traverse_linear_path(self, segment_end, exclude):
    lst = gfapy.SegmentEndsPath()
    current = segment_end.to_segment_end()
    current.segment = self.segment(current.segment)
    while True:
      after = current.segment.dovetails(current.end_type)
      before = current.segment.dovetails(current.end_type.invert)
      if (len(before) == 1 and len(after) == 1) or not lst:
        lst.append(gfapy.SegmentEnd(current.name, current.end_type))
        exclude.append(current.name)
        current = after[0].other_end(current).invert()
        if current.name in exclude:
          break
      elif len(before) == 1:
        lst.append(gfapy.SegmentEnd(current.name, current.end_type))
        exclude.append(current.name)
        break
      else:
        break
    if segment_end.end_type == "L":
      return lst[::-1]
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
                              options)
    if is_reversed:
      s = segment.sequence.rc[cut:]
    else:
      s = segment.sequence[cut:]
    if init:
      merged.sequence = s
      if options["merged_name"]:
        merged.name = options["merged_name"]
      else:
        merged.name = segment.name
      merged.LN = segment.LN
    else:
      if is_placeholder(segment.sequence):
        merged.sequence = gfapy.Placeholder()
      else:
        merged.sequence += s
      if not options["merged_name"]:
        merged.name += "_"
        merged.name += segment.name
      if merged.LN:
        if segment.LN:
          merged.LN += (segment.LN - cut)
        else:
          merged.LN = None

  def __create_merged_segment(self,segpath, options):
    merged = self.try_get_segment(segpath.first.segment).clone()
    jntag = options["jntag"] if options["jntag"] else "jn"
    merged.set(jntag, nil)
    total_cut = 0
    a = segpath[0]
    first_reversed = (a.end_type == "L")
    last_reversed = None
    if options["merged_name"] == "short"
      forbidden = (segment_names + path_names) # TODO: GFA2
      options["merged_name"] = "merged1"
      while options["merged_name"] in forbidden
        options["merged_name"] = options["merged_name"].next()
        # XXX String.next() in python?
    __add_segment_to_merged(merged, self.segment(a.segment), first_reversed, 0,
        True, options)
    if self._progress:
      self.__progress_log("merge_linear_paths", 0.95)
    for i in range(len(segpath)-1):
      b = segpath[i+1].to_segment_end().invert()
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
      __add_segment_to_merged(merged, self.segment(b.segment), last_reversed,
          cut, False, options)
      a = b.to_segment_end().invert()
      if self._progress:
        self.__progress_log("merge_linear_paths", 0.95)
    if not is_placeholder(merged.sequence):
      if self._version == "gfa1":
        if not merged.LN:
          merged.LN = len(merged.sequence)
        elif self._vlevel > 0 and merged.LN != len(merged.sequence):
          raise gfapy.InconsistencyError(
              "Computed sequence length {} ".format(merged.sequence.length)+
              "and computed LN {} differ".format(merged.LN)
    if merged.length is None:
      for count_tag in ["KC", "RC", "FC"]:
        merged.set(count_tag, None)
    else:
      factor = 1
      if options["cut_counts"]:
        factor = merged.length / (total_cut+merged.length)
      for count_tag,count in __sum_of_counts(segpath,factor).items():
        merged.set(count_tag, count)
    return merged, first_reversed, last_reversed

    def __list_merged(self, merged_name, segment_end, is_reversed):
      for l in self.segment(segment_end.segment).dovetails(segment_end.end_type):
        l2 = l.clone()
        if l2.to == segment_end.segment:
          l2.to = merged_name
          if is_reversed:
            l2.to_orient = l2.to_orient.invert()
        else:
          l2.from = merged_name
          if is_reversed:
            l2.from_orient = l2.from_orient.invert()
        self.add_line(l2)

