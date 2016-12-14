require_relative "../field_array"

# Methods for accessing the GFA header information.
#
# The GFA header is accessed using {#header RGFA#header},
# which returns a {RGFA::Line::Header} object.
#
# @example Accessing the header information
#   rgfa.header.VN # => “1.0”
#   rgfa.header.co = “This the header comment”
#   rgfa.header.ni = 100
#   rgfa.header.field_to_s(:ni) # => “ni:i:100”
#
# == Multiple header lines defining the same tag
#
# The specification does not explicitely forbid to have the same tag on
# different lines. To represent this case, a "field array"
# ({RGFA::FieldArray RGFA::FieldArray}) is used, which is an array of
# instances of a tag, from different lines of the header.
#
# @example Header with tags repeated on different lines (see {RGFA::FieldArray})
#   rgfa.header.ni # => RGFA::FieldArray<[100,200] @datatype: :i>
#   rgfa.header.ni[0] # 100
#   rgfa.header.ni << 200 # “200” is also OK
#   rgfa.header.ni.map!{|i|i-10}
#   rgfa.header.ni = [100,200,300].to_rgfa_field_array
#
# @example Adding instances of a tag (will go on different header lines)
#   rgfa.header.add(:xx, 100) # => 100 # single i tag, if .xx did not exist yet
#   rgfa.header.add(:xx, 100) # => RGFA::FieldArray<[100,100] @datatype: :i>
#   rgfa.header.add(:xx, 100) # => RGFA::FieldArray<[100,100,100] @datatype :i>
#
module RGFA::Lines::Headers

  # @return [RGFA::Line::Header] an header line representing the entire header
  #   information; if multiple header line were present, and they contain the
  #   same tag, the tag value is represented by a {RGFA::FieldArray}
  def header
    @records[:H]
  end

  # Header information in single-tag-lines.
  #
  # Returns an array of RGFA::Line::Header
  # objects, each containing a single field of the header.
  # @!macro readonly
  #   @note Read-only! The returned array containes copies of the original
  #     values, i.e.\ changes in the lines will not affect the RGFA object; to
  #     update the values in the RGFA use the #header method.
  # @return [Array<RGFA::Line::Header>]
  def headers
    @records[:H].split
  end

end
