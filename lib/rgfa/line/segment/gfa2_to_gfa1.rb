require_relative "../segment"

module RGFA::Line::Segment::GFA2ToGFA1

  # @return [Array<String>] an array of GFA1 field strings
  def to_gfa1_a
    a = ["S", field_to_s(:name, tag: false),
              field_to_s(:sequence, tag: false)]
    a << slen.to_gfa_field(datatype: :i, fieldname: :LN)
    tagnames.each {|fn| a << field_to_s(fn, tag: true)}
    return a
  end

end
