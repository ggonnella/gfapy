import gfapy

class Writer:
  def __str__(self):
    return "#" + str(self.spacer) + str(self.content)

  def to_list(self):
    return ["#", self.content, self.spacer]
