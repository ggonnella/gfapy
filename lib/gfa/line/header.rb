class GFA::Line::Header < GFA::Line

  def initialize(fields)
    super(fields, [["record_type", /H/]])
  end

end
