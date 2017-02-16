import gfapy

class CopyNumber:

  def set_default_count_tag(self, tag):
    self.default["count_tag"] = tag

  def set_count_unit_length(self, unit_length):
    self.default["unit_length"] = unit_length

  def delete_low_coverage_segments(mincov, count_tag=None, unit_length=None):
    if unit_length is None:
      unit_length = self.default["unit_length"]
    if count_tag is None:
      count_tag = self.default["count_tag"]
    for s in self.segments:
      cov = s.coverage(count_tag=count_tag, unit_length=unit_length)
      if cov < mincov:
        s.disconnect()

  def compute_copy_numbers(single_copy_coverage, mincov=None, count_tag=None,
                           cn_tag="cn", unit_length=None):
    if mincov is None:
      mincov = single_copy_coverage * 0.25
    if count_tag is None:
      count_tag = self.default["count_tag"]
    if unit_length is None:
      unit_length = self.default["unit_length"]
    for s in self.segments:
      cov = s.try_get_coverage(count_tag=count_tag, unit_length=unit_length)
      if cov < mincov:
        cn = 0
      elif cov < single_copy_coverage:
        cn = 1
      else:
        cn = round(cov / single_copy_coverage)
      s.set(cn_tag, cn)

  def apply_copy_number(segment, count_tag="cn", distribute="auto",
                        origin_tag="or", conserve_components=True):
    s, sn = segment_and_segment_name(segment)
    factor = s.try_get(count_tag)
    self.multiply_extended(sn, factor, distribute=distribute,
             copy_names=None, conserve_components=conserve_components,
             origin_tag=origin_tag)

  def apply_copy_numbers(count_tag="cn", distribute="auto",
                         origin_tag="or", conserve_components=True):
    for s in sorted(segments, key=lambda s:s.try_get(count_tag)):
      self.multiply_extended(s.name, s.get(count_tag), distribute=distribute,
               copy_names=None, conserve_components=conserve_components,
               origin_tag=origin_tag)
