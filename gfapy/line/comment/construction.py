import gfapy

class Construction:
  def _initialize_positional_fields(self, strings):
    self._init_field_value("content", "comment", strings[1], errmsginfo = strings)
    sp = strings[2] if len(strings) > 2 else " "
    self._init_field_value("spacer", "comment", sp, errmsginfo = strings)

  def _initialize_tags(self, strings):
    if len(strings) > 3:
      raise gfapy.ValueError("Comment lines do not support tags")
