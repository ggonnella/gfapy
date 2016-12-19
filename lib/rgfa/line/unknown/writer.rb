# Special string representation for virtual unknown lines
# @tested_in unit_unknown
module RGFA::Line::Unknown::Writer

  # A string representation of the unknown line
  # @return [String]
  def to_s
    "?record_type?\t#{name}\tco:Z:line_created_by_RGFA"
  end

end
