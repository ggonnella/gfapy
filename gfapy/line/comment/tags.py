import gfapy

class Tags:
  def method_missing(self, m, *args, block):
    raise NoMethodError(
      "undefined method `{}' for {}"
      .format(m, repr(self)))

  def set(self, fieldname, value):
    if str(fieldname) in ["comment", "sp"]:
      super().set(fieldname, value)
    else:
      raise gfapy.RuntimeError("Tags of comment lines cannot be set")
