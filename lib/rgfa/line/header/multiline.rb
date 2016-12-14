#
# Implementation of the support for multiple header line in the
# GFA file (which also may contain the same value defined multiple
# times in different lines).
#
module RGFA::Line::Header::Multiline

  # Set a header value (multi-value compatible).
  #
  # If a field does not exist yet, set it to value. If it exists and it is a
  # {RGFA::FieldArray}, add the value to the field array. If it exists and it
  # is not a field array, create a field array with the previous value and
  # the new one
  # @param fieldname [Symbol]
  # @param value [Object]
  # @param datatype [RGFA::Field::TAG_DATATYPE, nil] the datatype to use;
  #   the default is to determine the datatype according to the value or the
  #   previous values present in the field
  def add(fieldname, value, datatype=nil)
    fieldname = fieldname.to_sym
    prev = get(fieldname)
    if prev.nil?
      set_datatype(fieldname, datatype) if datatype
      set(fieldname, value)
      return self
    elsif !prev.kind_of?(RGFA::FieldArray)
      prev = RGFA::FieldArray.new(get_datatype(fieldname), [prev])
      set_existing_field(fieldname, prev)
    end
    if @vlevel > 1
      prev.vpush(value, datatype, fieldname)
    else
      prev << value
    end
    return self
  end

  # Compute the string representation of a field.
  #
  # @param fieldname [Symbol] the tag name of the field
  # @param tag [Boolean] <i>(defaults to: +false+)</i>
  #   return the tagname:datatype:value representation
  #
  # @raise [RGFA::NotFoundError] if field is not defined
  # @return [String] the string representation
  def field_to_s(fieldname, tag: false)
    prev = get(fieldname)
    if prev.kind_of?(RGFA::FieldArray)
      prev.validate_gfa_field(nil, fieldname) if @vlevel >= 2
      return tag ? prev.to_gfa_tag(fieldname)
                 : prev.to_gfa_field(fieldname: fieldname)
    else
      super
    end
  end

  # api_private

  # Split the header line into single-tag lines.
  #
  # If a tag is a FieldArray, this is splitted into multiple fields
  # with the same fieldname.
  # @return [Array<RGFA::Line::Header>]
  # @api private
  def split
    tags.map do |tagname, datatype, value|
      h = RGFA::Line::Header.new([], vlevel: @vlevel)
      h.set_datatype(tagname, datatype)
      h.set(tagname, value)
      h
    end
  end

  # Merge an additional {RGFA::Line::Header} line into this header line.
  # @param gfa_line [RGFA::Line::Header] the header line to merge
  # @return [self]
  # @api private
  def merge(gfa_line)
    gfa_line.tagnames.each do |of|
      add(of, gfa_line.get(of), gfa_line.get_datatype(of))
    end
    self
  end

  private

  # Array of tags data.
  #
  # Returns the tags as an array of [fieldname, datatype, value]
  # arrays. If a field is a FieldArray, this is splitted into multiple fields
  # with the same fieldname.
  # @return [Array<(Symbol, Symbol, Object)>]
  # @api private
  def tags
    retval = []
    tagnames.each do |of|
      value = get(of)
      if value.kind_of?(RGFA::FieldArray)
        value.each do |elem|
          retval << [of, value.datatype, elem]
        end
      else
        retval << [of, get_datatype(of), value]
      end
    end
    return retval
  end

end
