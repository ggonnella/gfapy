import gfapy

class Writer:
  def __str__(self):
    return "#{}{}".format(self.spacer, self.content)

  def to_list(self):
    return ["#", self.content, self.spacer]
