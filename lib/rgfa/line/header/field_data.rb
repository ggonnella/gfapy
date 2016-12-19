# Disallow editing the VN tag in connected header lines
# @tested_in api_header
module RGFA::Line::Header::FieldData

  private

  def set_existing_field(fieldname, value, set_reference: false)
    if fieldname == :VN and !get(:VN).nil? and self.connected?
      raise RGFA::RuntimeError,
        "The value of the header tag VN cannot be edited\n"+
        "For version conversion use to_gfa1 or to_gfa2"
    else
      super
    end
  end

end
