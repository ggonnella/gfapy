module RGFA::Line::Group::Ordered::ToGFA1

  def to_gfa1_a
    a = ["P"]
    if name.placeholder?
      raise RGFA::ValueError,
        "Conversion to GFA1 failed\n"+
        "The path name is a placeholder\t"+
        "Line: #{self}"
    end
    a << name.to_s
    segment_names = []
    captured_segments.each do |oline|
      oline.name.validate_gfa_field(:segment_name_gfa1)
      segment_names << oline.to_s
    end
    a << segment_names.join(",")
    overlaps = []
    captured_edges.each do |oline|
      oline.line.overlap.validate_gfa_field(:alignment_gfa1)
      overlaps << oline.line.overlap.to_s
    end
    a << overlaps.join(",")
    return a
  end

end
