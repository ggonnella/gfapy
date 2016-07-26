require_relative "error"

#
# Methods for the RGFA class, which allow to add lines.
#
module RGFA::LineCreators

  # Add a line to a RGFA
  #
  # @overload <<(gfa_line_string)
  #   @param [String] gfa_line_string representation of a RGFA line
  # @overload <<(gfa_line)
  #   @param [RGFA::Line] gfa_line instance of a subclass of RGFA::Line
  # @raise [RGFA::DuplicatedLabelError] if multiple segment or path lines
  #   with the same name are added
  # @return [RGFA] self
  def <<(gfa_line)
    gfa_line = gfa_line.to_rgfa_line(validate: @validate)
    rt = gfa_line.record_type
    case rt
    when :H
      add_header(gfa_line)
    when :S
      add_segment(gfa_line)
    when :L, :C
      add_link_or_containment(rt, gfa_line)
    when :P
      add_path(gfa_line)
    else
      raise # this never happens, as already catched by gfa_line init
    end
    return self
  end

  # Sets the header data
  # @param headers_data [Hash{Symbol:Object}] data contained in the header
  #   fields; the key +:multiple_values+ has a special meaning,
  #   see below.
  # <b>Multiple definitions of optional fields</b>
  #   The specification does not forbid that different header line contain
  #   the same optional field. If this is desired, then the +headers_data+
  #   for the optional field shall be set to an array, and
  #   +headers_data[:multiple_values]+ shall be an array containing the tag
  #   name.
  # @return [RGFA] self
  def set_headers(headers_data)
    rm(:headers)
    multiple_values = headers_data.delete(:multiple_values)
    multiple_values ||= []
    headers_data.each do |of, values|
      values = [values] if !multiple_values.include?(of) or
                           !values.kind_of?(Array)
      values.each do |value|
        h = "H".to_rgfa_line
        h.set(of, value)
        self << h
      end
    end
    return self
  end

  # Sets the value of a field in the header
  #
  # @param existing [Symbol] <i>(Default: +:ignore+)</i>
  #   what shall be done if a field already
  #   exist; +:replace+: the previous value is replaced by +value+;
  #   +:duplicate+: if the previous value is an array, +value+ is
  #   added to it, otherwise the field is set to +[previous value, value]+;
  #   +:ignore+ (and anything else): the new value is ignored.
  #
  # @return [RGFA] self
  def set_header_field(field, value, existing: :ignore)
    h = headers_data
    if !h.has_key?(field) or (existing == :replace)
      h[field] = value
      h[:multiple_values].delete(field)
    else
      if h[:multiple_values].include?(field)
        return nil if h[field].include?(value) and (existing != :duplicate)
        h[field] << value
      else
        return nil if h[field] == value and (existing != :duplicate)
        h[field] = [h[field], value]
        h[:multiple_values] << field
      end
    end
    set_headers(h)
    return self
  end

  private

  def add_header(gfa_line)
    @lines[:H] << gfa_line
  end

  def add_segment(gfa_line)
    validate_segment_and_path_name_unique!(gfa_line.name) if @validate
    @segment_names[gfa_line.name.to_sym] = @lines[:S].size
    @lines[:S] << gfa_line
  end

  def add_link_or_containment(rt, gfa_line)
    if rt == :L
      l = link(gfa_line.from_end, gfa_line.to_end)
      return if l == gfa_line
    end
    @lines[rt] << gfa_line
    [:from,:to].each do |e|
      sn = gfa_line.get(e)
      o = gfa_line.get(:"#{e}_orient")
      segment!(sn) if @segments_first_order
      @c.add(rt,@lines[rt].size-1,sn,e,o)
    end
  end

  def add_path(gfa_line)
    validate_segment_and_path_name_unique!(gfa_line.path_name) if @validate
    @path_names[gfa_line.path_name.to_sym] = @lines[:P].size
    @lines[:P] << gfa_line
    gfa_line.segment_names.each do |sn, o|
      segment!(sn) if @segments_first_order
      @c.add(:P,@lines[:P].size-1,sn)
    end
  end

  def validate_segment_and_path_name_unique!(sn)
    if @segment_names.has_key?(sn.to_sym) or @path_names.has_key?(sn.to_sym)
      raise RGFA::DuplicatedLabelError,
        "Segment or path name not unique '#{sn}'"
    end
  end

end

# Exception raised if a label for segment or path is duplicated
class RGFA::DuplicatedLabelError < RGFA::Error; end
