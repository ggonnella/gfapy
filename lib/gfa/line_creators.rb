#
# Methods for the GFA class, which allow to add lines.
#
module GFA::LineCreators

  def <<(gfa_line)
    gfa_line = gfa_line.to_gfa_line
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

  private

  def add_header(gfa_line)
    @lines["H"] << gfa_line
  end

  def add_segment(gfa_line)
    @lines["S"] << gfa_line
    validate_segment_and_path_name_unique!(gfa_line.name)
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
    validate_segment_and_path_name_unique!(gfa_line.path_name)
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
