import gfapy

class Tags:

  def set(self, fieldname, value):
    if fieldname in ["content", "spacer"]:
      return super().set(fieldname, value)
    else:
      raise gfapy.RuntimeError("Tags of comment lines cannot be set")
