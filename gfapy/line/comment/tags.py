import gfapy

class Tags:

  def set(self, fieldname, value):
    """Set the value of a field.

    The generic Line.set() method is overwritten for comments,
    in order to disallow tags.
    """
    if fieldname in ["content", "spacer"]:
      return super().set(fieldname, value)
    else:
      raise gfapy.RuntimeError("Tags of comment lines cannot be set")
