# A header line of a RGFA file
#
# For examples on how to set the header data, see {RGFA::Headers}.
#
# @see RGFA::Line
class RGFA::Line::Header < RGFA::Line

  RECORD_TYPE = :H
  versions = [:"1.0", :"2.0", :generic]
  posfields = {}
  versions.each {|v| posfields[v] = []}
  POSFIELDS = posfields
  PREDEFINED_TAGS = [:VN]
  FIELD_ALIAS = {}
  DATATYPE = {
    :VN => :Z
  }

  define_field_methods!

  # Set a header value (multi-value compatible).
  #
  # If a field does not exist yet, set it to value. If it exists and it is a
  # {RGFA::FieldArray}, add the value to the field array. If it exists and it
  # is not a field array, create a field array with the previous value and
  # the new one
  # @param fieldname [Symbol]
  # @param value [Object]
  # @param datatype [RGFA::Line::TAG_DATATYPE, nil] the datatype to use;
  #   the default is to determine the datatype according to the value or the
  #   previous values present int the field
  def add(fieldname, value, datatype=nil)
    fieldname = fieldname.to_sym
    prev = get(fieldname)
    if prev.nil?
      set_datatype(fieldname, datatype) if datatype
      set(fieldname, value)
      return self
    elsif !prev.kind_of?(RGFA::FieldArray)
      prev = RGFA::FieldArray.new(get_datatype(fieldname), [prev])
      set_datatype(fieldname, :J)
      set(fieldname,prev)
    end
    prev.push_with_validation(value, datatype, fieldname)
    return self
  end

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

  # Split the header line into single-tag lines.
  #
  # If a tag is a FieldArray, this is splitted into multiple fields
  # with the same fieldname.
  # @return [Array<RGFA::Line::Header>]
  # @api private
  def split
    tags.map do |tagname, datatype, value|
      h = RGFA::Line::Header.new([], validate: @validate)
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

end
