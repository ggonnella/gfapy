import gfapy

class CapturedPath:

  @property
  def captured_edges(self):
    if not self.is_connected():
      raise gfapy.RuntimeError(
        "Captured path cannot be computed\n"+
        "Line is not connected to a GFA instance\n"+
        "Line: {}".format(self))
    return self.links

  @property
  def captured_segments(self):
    if not self.is_connected():
      raise gfapy.RuntimeError(
        "Captured path cannot be computed\n"+
        "Line is not connected to a GFA instance\n"+
        "Line: {}".format(self))
    return self.segment_names

  @property
  def captured_path(self):
    if not self.is_connected():
      raise gfapy.RuntimeError(
        "Captured path cannot be computed\n"+
        "Line is not connected to a GFA instance\n"+
        "Line: {}".format(self))
    retval = []
    if len(self.segment_names) == 1:
      retval.append(self.segment_names[0])
    else:
      for i in range(len(self.segment_names) - 1):
        retval.append(self.segment_names[i])
        retval.append(self.links[i])
      retval.append(self.segment_names[-1])
      if len(self.segment_names) == len(self.links):
        retval.append(self.links[-1])
        retval.append(self.segment_names[0])
    return retval
