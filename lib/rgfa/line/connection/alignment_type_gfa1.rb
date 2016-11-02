require_relative "../connection"

module RGFA::Line::Connection::AlignmentTypeGFA1

  def alignment_type
    return record_type
  end

end
