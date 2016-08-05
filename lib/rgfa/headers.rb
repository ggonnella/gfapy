require_relative "error"
require_relative "field_array"

#
# Methods for the RGFA class, which allow to handle headers in the graph.
#
# It is unclear if only a single header is allowed. If multiple H lines are
# allowed, then the same tag may be set on different lines.
# RGFA allows for both possibilities.
# The header is accessed using #header.
# This returns a RGFA::Line::Header object.
#
# <b>Single header line, or multiple lines but no repeated tags </b>
# @example
#   rgfa.header.VN # => “1.0”
#   rgfa.header.co = “This the header comment”
#   rgfa.header.ni = 100
#   rgfa.header.field_to_s(:ni) # => “ni:i:100”
#
# <b> Multiple header lines, with repeated tags: RGFA::FieldArray</b>
#
# Repeated tags are represented using a subclass of Array (RGFA::FieldArray):
# @example
#   rgfa.header.ni # => RGFA::FieldArray<[100,200] @datatype: :i>
#   rgfa.header.ni[0] # 100
#   rgfa.header.ni << 200 # “200” is also OK
#   rgfa.header.ni.map!{|i|i-10}
#   rgfa.header.ni = [100,200,300].to_rgfa_field_array
#
# <b>RGFA::Line::Header#add</b>
#
# Using the header add method, it is possible to add further values of a tag,
# one at a time:
#
# @example:
#   rgfa.header.add(:xx, 100) # => 100 # single i tag, if .xx did not exist yet
#   rgfa.header.add(:xx, 100) # => RGFA::FieldArray<[100,100] @datatype: :i>
#   rgfa.header.add(:xx, 100) # => RGFA::FieldArray<[100,100,100] @datatype :i>
module RGFA::Headers

  # @return [RGFA::Line::Header] an header line representing the entire header
  #   information; if multiple header line were present, and they contain the
  #   same tag, the tag value is represented by a RGFA::FieldArray
  def header
    @headers
  end

  # Header information of the graph in form of RGFA::Line::Header
  # objects (each containing a single field of the header).
  # @return [Array<RGFA::Line::Header>]
  def headers
    @headers.split
  end

  def each_header(&block)
    headers.each(&block)
  end

  # Remove all headers
  # @return [RGFA] self
  def delete_headers
    init_headers
    return self
  end

  def add_header(gfa_line)
    gfa_line = gfa_line.to_rgfa_line(validate: @validate)
    @headers.merge(gfa_line)
  end

end
