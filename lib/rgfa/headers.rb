require_relative "error"
require_relative "field_array"

#
# Methods for the RGFA class, which allow to handle headers in the graph.
#
module RGFA::Headers

  # Sets the value of a field in the header
  #
  # @param existing [Symbol] <i>(Default: +:replace+)</i>
  #   what shall be done if a field already
  #   exist; +:replace+: the previous value is replaced by +value+;
  #   +:add+: if multiple previous values exist as a RGFA::FieldArray,
  #   +value+ is added to it, otherwise the field is set to a RGFA::FieldArray
  #   with the content [previous_value, value];
  #   +:ignore+ (and anything else)
  #
  # @return [RGFA] self
  def set_header_field(fieldname, value, datatype: nil, existing: :replace)
    fieldname = fieldname.to_sym
    prev = @headers.get(fieldname)
    if prev.nil?
      @headers.set_datatype(fieldname, datatype) if datatype
      @headers.set(fieldname, value)
      return self
    elsif existing == :replace
      if datatype
        @headers.set_datatype(fieldname, datatype)
      elsif prev.kind_of?(RGFA::FieldArray)
        @headers.set_datatype(fieldname, prev.datatype)
      end
      @headers.set(fieldname, value)
      return self
    elsif existing == :ignore
      return self
    elsif !prev.kind_of?(RGFA::FieldArray)
      prev = RGFA::FieldArray.new(@headers.get_datatype(fieldname), [prev])
      @headers.set_datatype(fieldname, :J)
      @headers.set(fieldname,prev)
    end
    prev.push_with_validation(value, datatype, fieldname)
    return self
  end

  # Header information of the graph in form of RGFA::Line::Header
  # objects (each containing a single field of the header).
  # @return [Array<RGFA::Line::Header>]
  def headers
    header_fields.map do |tagname, datatype, value|
      h = RGFA::Line::Header.new([], validate: @validate)
      h.set_datatype(tagname, datatype)
      h.set(tagname, value)
      h
    end
  end

  def each_header(&block)
    headers.each(&block)
  end

  # @return [Array<Array{Tagname,Datatype,Value}>] all header fields;
  def header_fields
    retval = []
    @headers.optional_fieldnames.each do |of|
      value = @headers.get(of)
      if value.kind_of?(RGFA::FieldArray)
        value.each do |elem|
          retval << [of, value.datatype, elem]
        end
      else
        retval << [of, @headers.get_datatype(of), value]
      end
    end
    return retval
  end

  # Remove all headers
  # @return [RGFA] self
  def delete_headers
    init_headers
    return self
  end

  # @return [RGFA::Line::Header] an header line representing the entire header
  #   information; if multiple header line were present, and they contain the
  #   same tag, the tag value is represented by a RGFA::FieldArray
  def header
    @headers
  end

  def add_header(gfa_line)
    gfa_line = gfa_line.to_rgfa_line(validate: @validate)
    gfa_line.optional_fieldnames.each do |of|
      value = gfa_line.get(of)
      datatype = gfa_line.get_datatype(of)
      set_header_field(of, value, datatype: datatype, existing: :add)
    end
  end

end
