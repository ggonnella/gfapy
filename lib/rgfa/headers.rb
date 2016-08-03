require_relative "error"

#
# Methods for the RGFA class, which allow to handle headers in the graph.
#
module RGFA::Headers

  # Sets the value of a field in the header
  #
  # @param existing [Symbol] <i>(Default: +:ignore+)</i>
  #   what shall be done if a field already
  #   exist; +:replace+: the previous value is replaced by +value+;
  #   +:duplicate+: if multiple previous values exist as an array, +value+ is
  #   added to it, otherwise the field is set to +[previous value, value]+;
  #   +:ignore+ (and anything else): the new value is ignored.
  #
  # @return [RGFA] self
  def set_header_field(field, value, existing: :ignore)
    if !@headers.has_key?(field) or (existing == :replace)
      @headers[field] = [value]
      @headers[:multiple_values].delete(field)
    elsif (existing == :duplicate)
      if @headers[:multiple_values].include?(field)
        @headers[field] << [value]
      else
        @headers[field] = [@headers[field], [value]]
        @headers[:multiple_values] << field
      end
    end
    return self
  end

  # Header information of the graph in form of RGFA::Line::Header
  # objects (each containing a single field of the header).
  # @return [Array<RGFA::Line::Header>]
  def headers
    header_fields.map do |tagname, datatype, value|
      RGFA::Line::Header.new({tagname => [value, datatype]})
    end
  end

  def each_header(&block)
    headers.each(&block)
  end

  # @return [Array<Array{Tagname,Datatype,Value}>] all header fields;
  def header_fields
    retval = []
    @headers.each do |of, values|
      next if of == :multiple_values
      if @headers[:multiple_values].include?(of)
        values.each do |value|
          retval << [of, value[1], value[0]]
        end
      else
        retval << [of, values[1], values[0]]
      end
    end
    return retval
  end

  # Remove all headers
  # @return [RGFA] self
  def delete_headers
    @headers = {:multiple_values => []}
  end

  def add_header(gfa_line)
    gfa_line = gfa_line.to_rgfa_line(validate: @validate)
    gfa_line.optional_fieldnames.each do |of|
      value = gfa_line.get(of)
      datatype = gfa_line.get_datatype(of)
      if @headers.has_key?(of)
        if !@headers[:multiple_values].include?(of)
          @headers[of] = [@headers[of]]
          @headers[:multiple_values] << of
        end
        @headers[of] << [value, datatype]
      else
        @headers[of] = [value, datatype]
      end
    end
  end

end
