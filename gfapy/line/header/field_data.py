import gfapy

class FieldData:
  """
  Disallow editing the VN tag in connected header lines
  """

  def _set_existing_field(self, fieldname, value, set_reference=False):
    if fieldname == "VN" and self.get("VN") is not None and self.is_connected():
      raise gfapy.RuntimeError(
        "The value of the header tag VN cannot be edited\n"+
        "For version conversion use to_gfa1 or to_gfa2")
    else:
      super()._set_existing_field(fieldname, value,
                                  set_reference=set_reference)
