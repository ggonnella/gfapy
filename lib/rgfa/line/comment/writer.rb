module RGFA::Line::Comment::Writer

  def to_s
    "##{spacer}#{content}"
  end

  alias_method :to_gfa1_s, :to_s
  alias_method :to_gfa2_s, :to_s

  def to_a
    ["#", content, spacer]
  end

end
