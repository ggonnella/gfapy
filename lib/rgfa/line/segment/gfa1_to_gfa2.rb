require_relative "../segment"

module RGFA::Line::Segment::GFA1ToGFA2

  # @return [Array<String>] an array of GFA2 field strings
  def to_gfa2_a
    a = ["S", field_to_s(:name, tag: false), length!.to_s,
              field_to_s(:sequence, tag: false)]
    (tagnames-[:LN]).each {|fn| a << field_to_s(fn, tag: true)}
    return a
  end

end
