module RGFA::Line::Comment::Writer

  def to_s
    "##{spacer}#{content}"
  end

  def to_a
    ["#", content, spacer]
  end

end
