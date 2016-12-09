module RGFA::Line::Group::Path::CapturedPath

  def captured_edges
    if !connected?
      raise RGFA::RuntimeError,
        "Captured path cannot be computed\n"+
        "Line is not connected to a RGFA instance\n"+
        "Line: #{self}"
    end
    links
  end

  def captured_segments
    if !connected?
      raise RGFA::RuntimeError,
        "Captured path cannot be computed\n"+
        "Line is not connected to a RGFA instance\n"+
        "Line: #{self}"
    end
    segment_names
  end

  def captured_path
    if !connected?
      raise RGFA::RuntimeError,
        "Captured path cannot be computed\n"+
        "Line is not connected to a RGFA instance\n"+
        "Line: #{self}"
    end
    retval = []
    (segment_names.size-1).times do |i|
      retval << segment_names[i]
      retval << links[i]
    end
    retval << segment_names[-1]
    if segment_names.size == links.size
      retval << links[-1]
      retval << segment_names[0]
    end
    return retval
  end

end
