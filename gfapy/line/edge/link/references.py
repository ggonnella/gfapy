class References:

  def _process_not_unique(self, previous):
    if self.is_complement(previous):
      pass
    else:
      super()._process_not_unique(previous)
