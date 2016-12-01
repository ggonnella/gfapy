require "set"

module RGFA::Line::Group::Unordered::InducedSet

  def induced_set
    if !connected?
      raise RGFA::RuntimeError,
        "Induced set cannot be computed\n"+
        "Line is not connected to a RGFA instance\n"+
        "Line: #{self}"
    end
    iss = induced_segments_set
    ise = compute_induced_edges_set(iss)
    (iss + ise).freeze
  end

  def induced_edges_set
    if !connected?
      raise RGFA::RuntimeError,
        "Induced set cannot be computed\n"+
        "Line is not connected to a RGFA instance\n"+
        "Line: #{self}"
    end
    compute_induced_edges_set(induced_segments_set).freeze
  end

  def induced_segments_set
    if !connected?
      raise RGFA::RuntimeError,
        "Induced set cannot be computed\n"+
        "Line is not connected to a RGFA instance\n"+
        "Line: #{self}"
    end
    segments_set = Set.new
    items.each do |item|
      case item
      when Symbol
        raise RGFA::RuntimeError,
          "Induced set cannot be computed; a reference has not been resolved\n"+
          "Line: #{self}\n"+
          "Unresolved reference: #{item.line} (Symbol found)"
      when RGFA::Line::Segment::GFA2
        check_induced_set_elem_connected(item)
        segments_set << item
      when RGFA::Line::Edge::GFA2
        check_induced_set_elem_connected(item)
        [item.sid1.line, item.sid2.line].each do |sl|
          check_induced_set_elem_connected(sl)
          segments_set << sl
        end
      when RGFA::Line::Group::Ordered
        check_induced_set_elem_connected(item)
        subset = item.induced_segments_set
        raise RGFA::AssertionError if subset.empty?
        subset.each do |elem|
          segments_set << elem.line
        end
      when RGFA::Line::Group::Unordered
        check_induced_set_elem_connected(item)
        subset = item.induced_segments_set
        raise RGFA::AssertionError if subset.empty?
        subset.each do |elem|
          segments_set << elem
        end
      when RGFA::Line::Unknown
        raise RGFA::RuntimeError,
          "Induced set cannot be computed; a reference has not been resolved\n"+
          "Line: #{self}\n"+
          "Unresolved reference: #{item.name} (Virtual unknown line)"
      else
        raise RGFA::TypeError,
          "Line: #{self}\t"+
          "Cannot compute induced set:\t"+
          "Error: items of type #{item.class} are not supported\t"+
          "Unsupported item: #{item}"
      end
    end
    return segments_set.to_a.freeze
  end

  private

  def check_induced_set_elem_connected(item)
    if !item.connected?
      raise RGFA::RuntimeError,
        "Cannot compute induced set\n"+
        "Non-connected element found\n"+
        "Item: #{item}\nLine: #{self}"
    end
  end

  def compute_induced_edges_set(segments_set)
    edges_set = Set.new
    segments_set.each do |item|
      item.edges.each do |edge|
        edges_set << edge if segments_set.include?(edge.other(item))
      end
    end
    return edges_set.to_a
  end

end
