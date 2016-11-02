module RGFA::Line::Header::VersionConversion

  # Return the string representation of the tags, changing the value
  #   of the VN tag to 2.0, if this is present
  # @return [Array<String>] array of strings representing the tags
  def to_gfa2_a
    a = ["H"]
    (a << "VN:Z:2.0") if self.VN
    (tagnames-:VN).each {|fn| a << field_to_s(fn, tag: true)}
    return a
  end

  # Return the string representation of the tags, changing the value
  #   of the VN tag to 1.0, if this is present
  # @return [Array<String>] array of strings representing the tags
  def to_gfa1_a
    a = ["H"]
    (a << "VN:Z:1.0") if self.VN
    (tagnames-:VN).each {|fn| a << field_to_s(fn, tag: true)}
    return a
  end

end
