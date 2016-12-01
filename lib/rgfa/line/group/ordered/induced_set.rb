require "set"

module RGFA::Line::Group::Ordered::InducedSet

  def induced_segments_set
    induced_set.select{|x|x.line.kind_of?(RGFA::Line::Segment::GFA2)}
  end

  def induced_edges_set
    induced_set.select{|x|x.line.kind_of?(RGFA::Line::Edge::GFA2)}
  end

  def induced_set
    if !connected?
      raise RGFA::RuntimeError,
        "Induced set cannot be computed\n"+
        "Line is not connected to a RGFA instance\n"+
        "Line: #{self}"
    end
    compute_induced_set[0]
  end

  protected

  def compute_induced_set
    path, prev_edge = [], false
    items.each do |item|
      path, prev_edge = push_item_on_se_path(path, prev_edge, item)
    end
    return path, prev_edge
  end

  private

  def push_item_on_se_path(path, prev_edge, item)
    case item.line
    when Symbol
      raise RGFA::RuntimeError,
        "Induced set cannot be computed; a reference has not been resolved\n"+
        "Line: #{self}\n"+
        "Unresolved reference: #{item.line} (Symbol found)"
    when RGFA::Line::Segment::GFA2
      if !item.line.connected?
        raise RGFA::RuntimeError,
          "Induced set cannot be computed; item is not connected\n"+
          "Line: #{self}\n"+
          "Item: #{item.line}"
      end
      push_segment_on_se_path(path, prev_edge, item)
      prev_edge = false
    when RGFA::Line::Edge::GFA2
      if !item.line.connected?
        raise RGFA::RuntimeError,
          "Induced set cannot be computed; item is not connected\n"+
          "Line: #{self}\n"+
          "Item: #{item.line}"
      end
      if path.empty?
        push_first_edge_on_se_path(path, items)
      else
        push_nonfirst_edge_on_se_path(path, item)
      end
      prev_edge = true
    when RGFA::Line::Group::Ordered
      if !item.line.connected?
        raise RGFA::RuntimeError,
          "Induced set cannot be computed; item is not connected\n"+
          "Line: #{self}\n"+
          "Item: #{item.line}"
      end
      subpath, prev_edge_subpath = item.line.compute_induced_set
      raise RGFA::AssertionError if subpath.empty?
      if item.orient == :+
        subpath.each do |subpath_item|
          path, prev_edge =
            push_item_on_se_path(path, prev_edge, subpath_item)
        end
      else
        subpath.reverse.each do |subpath_item|
          path, prev_edge =
            push_item_on_se_path(path, prev_edge, subpath_item.invert)
        end
      end
      prev_edge = prev_edge_subpath
    when RGFA::Line::Unknown
      raise RGFA::RuntimeError,
        "Induced set cannot be computed; a reference has not been resolved\n"+
        "Line: #{self}\n"+
        "Unresolved reference: #{item.name} (Virtual unknown line)"
    else
      raise RGFA::TypeError,
        "Line: #{self}\t"+
        "Cannot compute induced set:\t"+
        "Error: items of type #{item.line.class} are not supported\t"+
        "Unsupported item: #{item}"
    end
    return path, prev_edge
  end

  def push_first_edge_on_se_path(path, items)
    oriented_edge = items[0]
    oss = [oriented_edge.line.sid1, oriented_edge.line.sid2]
    oss.map!{|x|x.invert} if oriented_edge.orient == :"-"
    if items.size > 1
      nextitem = items[1]
      case nextitem.line
      when RGFA::Line::Segment::GFA2
        oss.reverse! if nextitem == oss[0]
        # if oss does not include nextitem an error will be raised
        # in the next iteration, so does not need to be handled here
      when RGFA::Line::Edge::GFA2
        oss_of_next = [nextitem.line.sid1, nextitem.line.sid2]
        oss_of_next.map!{|x|x.invert} if nextitem.orient == :"-"
        oss.reverse! if oss_of_next.include?(oss[0])
        # if oss_of_next have no element in common with oss an error will be
        # raised in the next iteration, so does not need to be handled here
      when RGFA::Line::Group::Ordered
        subpath = item.line.induced_set
        return if subpath.empty? # does not need to be further handled here
        if item.orient == :+
          firstsubpathsegment = supath[0]
        else
          firstsubpathsegment = supath[-1].invert
        end
        oss.reverse! if firstsubpathsegment == oss[0]
        # if oss does not include in firstsubpathsegment
        # error will be raised in next iteration, ie not handled here
      else
        # don't need to handle here other cases, as they will be handled
        # in the next iteration of push_item_on_se_path
      end
    end
    path << oss[0]
    path << oriented_edge
    path << oss[1]
  end

  def push_nonfirst_edge_on_se_path(path, oriented_edge)
    prev_os = path[-1]
    path << oriented_edge
    possible_prev = [oriented_edge.line.sid1, oriented_edge.line.sid2]
    possible_prev.map!{|os|os.invert} if oriented_edge.orient == :"-"
    if prev_os == possible_prev[0]
      path << possible_prev[1]
    elsif prev_os == possible_prev[1]
      path << possible_prev[0]
    else
      raise RGFA::NotFoundError,
        "Path is not valid, elements are not contiguous\n"+
        "Line: #{self}\n"+
        "Previous elements:\n"+
        path.map{|e|"  #{e} (#{e.line})\n"}.join+
        "Current element:\n"+
        "  #{oriented_edge} (#{oriented_edge.line})"
    end
  end

  def push_segment_on_se_path(path, prev_edge, oriented_segment)
    if !path.empty?
      case path[-1].line
      when RGFA::Line::Segment::GFA2
        if prev_edge
          check_s_is_as_expected(path, oriented_segment)
          return # do not add segment, as it is already there
        else
          path << find_edge_from_path_to_segment(path, oriented_segment)
        end
      when RGFA::Line::Edge::GFA2
        check_s_to_e_contiguity(path, oriented_segment)
      else
        raise RGFA::AssertionError
      end
    end
    path << oriented_segment
  end

  def check_s_is_as_expected(path, oriented_segment)
    if path[-1] != oriented_segment
      raise RGFA::InconsistencyError,
        "Path is not valid\n"+
        "Line: #{self}\n"+
      "Previous elements:\n"+
      path[0..-2].map{|e|"  #{e} (#{e.line})\n"}+
      "Expected element:\n"+
      "  #{path[-1]} (#{path[-1].line})\n"
      "Current element:\n"+
        "  #{segment} (#{segment.line})\n"
    end
  end

  def check_s_to_e_contiguity(path, oriented_segment)
    # check that segment is an extremity of path[-1]
    # and that the other extremity is path[-2]
    if !(path[-1].sid1 == segment and path[-1].sid2 == path[-2]) and
       !(path[-1].sid1 == path[-2] and path[-1].sid2 == segment)
    raise RGFA::InconsistencyError,
      "Path is not valid\n"+
      "Line: #{self}\n"+
      "Previous elements:\n"+
      path.map{|e|"  #{e} (#{e.line})\n"}.join+
      "Current element:\n"+
      "  #{oriented_segment} (#{oriented_segment.line})\n"
    end
  end

  def find_edge_from_path_to_segment(path, oriented_segment)
    edges = []
    oriented_segment.line.edges.each do |edge|
      if (edge.sid1 == oriented_segment and edge.sid2 == path[-1]) or
           (edge.sid1 == path[-1] and edge.sid2 == oriented_segment)
        edges << OL[edge, :+]
      elsif (edge.sid1 == oriented_segment.invert and
               edge.sid2 == path[-1].invert) or
                 (edge.sid1 == path[-1].invert and
                    edge.sid2 == oriented_segment.invert)
        edges << OL[edge, :-]
      end
    end
    if edges.size == 0
      raise RGFA::NotFoundError,
        "Path is not valid, segments are not contiguous\n"+
        "Line: #{self}\n"+
      "Previous elements:\n"+
      path.map{|e|"  #{e} (#{e.line})\n"}.join+
      "Current element:\n"+
      "  #{oriented_segment} (#{oriented_segment.line})\n"
    elsif edges.size > 1
      raise RGFA::NotUniqueError,
        "Path is not unique\n"+
        "Line: #{self}\n"+
      "Previous elements:\n"+
      path.map{|e|"  #{e} (#{e.line})\n"}.join+
      "Current element:\n"+
      "  #{oriented_segment} (#{oriented_segment.line})\n"+
      "Possible edges\n"+
      edges.map{|e|"  #{e} (#{e.line})\n"}.join
    end
    return edges[0]
  end

  def check_induced_set_elem_connected(item)
    if !item.connected?
      raise RGFA::RuntimeError,
        "Cannot compute induced set\n"+
        "Non-connected element found\n"+
        "Item: #{item}\nLine: #{self}"
    end
  end

end
