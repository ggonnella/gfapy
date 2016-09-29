import gfapy

class Writer:
  def __str__(self):
    return "#{}{}".format(self.comment, self.spacer)

  def to_list(self):
    return ["#", self.content, self.spacer]
