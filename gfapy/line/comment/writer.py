class Writer:
  def __str__(self):
    return "#" + str(self.spacer) + str(self.content)

  def to_list(self):
    """Convert the content of the comment line to a list.

    The generic to_list() method of Line is overwritten,
    in order to support an optional spacer specification.
    """
    return ["#", self.content, self.spacer]
