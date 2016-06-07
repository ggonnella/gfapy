#
# Methods for the GFA class, which allow to add lines.
#
module GFA::LineCreators

  def <<(gfa_line)
    gfa_line = gfa_line.to_gfa_line(validate: @validate)
    rt = gfa_line.record_type
    case rt
    when "H"
      add_header(gfa_line)
    when "S"
      add_segment(gfa_line)
    when "L", "C"
      add_link_or_containment(rt, gfa_line)
    when "P"
      add_path(gfa_line)
    else
      raise # this never happens, as already catched by gfa_line init
    end
  end

  def set_headers(headers_data)
    rm(:headers)
    multiple_values = headers_data.delete(:multiple_values)
    multiple_values ||= []
    headers_data.each do |of, values|
      values = [values] if !multiple_values.include?(of)
      if !values.kind_of?(Array)
        raise "Field #{of} listed in multiple_values key, but is not an array"
      end
      values.each do |value|
        h = "H".to_gfa_line
        h.send(:"#{of}=", value)
        self << h
      end
    end
  end

  def set_header_field(field, value, replace: false, duplicate: false)
    h = headers_data
    if !h.has_key?(field) or replace
      h[field] = value
      h[:multiple_values].delete(field)
    else
      if h[:multiple_values].include?(field)
        return self if h[field].include?(value) and !duplicate
        h[field] << value
      else
        return self if h[field] == value and !duplicate
        h[field] = [h[field], value]
        h[:multiple_values] << field
      end
    end
    set_headers(h)
    self
  end

  private

  def add_header(gfa_line)
    @lines["H"] << gfa_line
  end

  def add_segment(gfa_line)
    @lines["S"] << gfa_line
    validate_segment_and_path_name_unique!(gfa_line.name) if @validate
    @segment_names << gfa_line.name
  end

  def add_link_or_containment(rt, gfa_line)
    @lines[rt] << gfa_line
    [:from,:to].each do |e|
      sn = gfa_line.send(e)
      o = gfa_line.send(:"#{e}_orient")
      segment!(sn) if @segments_first_order
      @c.add(rt,@lines[rt].size-1,sn,e,o)
    end
  end

  def add_path(gfa_line)
    @lines["P"] << gfa_line
    validate_segment_and_path_name_unique!(gfa_line.path_name) if @validate
    @path_names << gfa_line.path_name
    gfa_line.segment_names.each do |sn, o|
      segment!(sn) if @segments_first_order
      @c.add("P",@lines["P"].size-1,sn)
    end
  end

  def validate_segment_and_path_name_unique!(sn)
    if @segment_names.include?(sn) or @path_names.include?(sn)
      raise ArgumentError, "Segment or path name not unique '#{sn}'"
    end
  end

end
