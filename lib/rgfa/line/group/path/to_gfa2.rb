module RGFA::Line::Group::Path::ToGFA2

  def to_gfa2_a
    items = []
    captured_path.each do |oline|
      case oline.line
      when RGFA::Line::Segment::GFA1
        items << oline.to_s
      when RGFA::Line::Edge::Link
        eid = oline.line.eid
        if eid.placeholder?
          raise RGFA::ValueError,
            "Links has no identifier\n"+
            "Path conversion to GFA2 failed"
        end
        items << eid + oline.orient.to_s
      end
    end
    a = ["O"]
    a << field_to_s(:path_name)
    a << items.join(" ")
    return a
  end

end
