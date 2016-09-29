import gfapy

class Validation:
  def _validate_lists_size(self):
    n_overlaps = len(self.overlaps)
    n_segments = len(self.segment_names)
    if n_overlaps == n_segments - 1:
      # case 1: linear path
      return True
    elif n_overlaps == 1 and not self.overlaps[0]:
      # case 2: linear path, single "*" to represent overlaps which are all "*"
      return True
    elif n_overlaps == n_segments:
      # case 3: circular path
      pass
    else:
      raise gfapy.InconsistencyError(
        "Path has {} oriented segments, ".format(n_segments)+
        "but {} overlaps".format(n_overlaps))

  def _validate_record_type_specific_info(self):
    self._validate_lists_size()
