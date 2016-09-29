import gfapy

class Init:
  def _initialize_positional_fields(self, strings):
    self._init_field_value("content", "comment", strings[0], errmsginfo = strings)
    sp = strings[1] if len(strings) > 1 else " "
    self._init_field_value("spacer", "comment", sp, errmsginfo = strings)

  def _initialize_tags(self, strings):
    if len(strings) > 2:
      raise gfapy.ValueError("Comment lines do not support tags")
