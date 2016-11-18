RGFA::Line::Edge::GFA1 ||= Module.new

# Methods for the access of / convertion from a GFA1 link/containment
# as / to a GFA2 edge
#
# Requirements: +from+, +from_orient+, +to+, +to_orient+.
module RGFA::Line::Edge::GFA1::ToGFA2

  def name
    i = get(:ID)
    if i.nil?
      return RGFA::Placeholder.new
      #i = "#{from_name}#{from_orient} #{to_name}#{to_orient} #{overlap}"
    end
    return i
  end
  alias_method :eid, :name
  alias_method :to_sym, :name

  def sid1
    (from_orient == :+ or to_orient == :-) ? from : to
  end

  def sid2
    (from_orient == :+ or to_orient == :-) ? to : from
  end

  def or2
    if from_orient == :+
      to_orient
    elsif to_orient == :-
      :"+"
    else
      :"-"
    end
  end

  def beg1
    if from_orient == :+ or to_orient == :-
      from_cords[0]
    else
      to_coords[0]
    end
  end

  def end1
    if from_orient == :+ or to_orient == :-
      from_cords[1]
    else
      to_coords[1]
    end
  end

  def beg2
    if from_orient == :+ or to_orient == :-
      from_cords[1]
    else
      to_coords[1]
    end
  end

  def end2
    if from_orient == :+ or to_orient == :-
      to_cords[1]
    else
      from_coords[1]
    end
  end

  def alignment
    if from_orient == :+ or to_orient == :-
      overlap
    else
      complement_overlap
    end
  end

  def to_gfa2_a
    a = ["E"]
    i = get(:ID)
    a << (i ? i.to_s : "*")
    if from_orient == :+ or to_orient == :-
      a << field_to_s(:from)
      a << ((from_orient == :+) ? field_to_s(:to_orient) : "+")
      a << field_to_s(:to)
      a += from_coords.map(&:to_s)
      a += to_coords.map(&:to_s)
      a << field_to_s(:overlap)
    else
      a << field_to_s(:to)
      a << "-"
      a << field_to_s(:from)
      a += to_coords.map(&:to_s)
      a += from_coords.map(&:to_s)
      a << complement_overlap.to_s
    end
    (tagnames-[:ID]).each {|fn| a << field_to_s(fn, tag: true)}
    return a
  end

  # GFA2 positions of the alignment on the +from+ segment
  # @!macro [new] coords
  #   @return [(Integer|Lastpos,Integer|Lastpos)] begin and end
  #   @raise [RGFA::ValueError] if the overlap is not specified
  #   @raise [RGFA::RuntimeError] if the segment length cannot be determined,
  #     because the segment line is unknown
  #   @raise [RGFA::ValueError] if the segment length is not specified
  #     in the segment line
  def from_coords
    if overlap.kind_of?(RGFA::Placeholder)
      raise RGFA::ValueError,
        "Link: #{self.to_s}\n"+
        "Missing overlap, cannot compute overlap coordinates"
    end
    if from_orient == :+
      if !from.kind_of?(RGFA::Line)
        raise RGFA::RuntimeError,
          "Line not embedded in a RGFA object"
      end
      if from.length.nil?
        raise RGFA::ValueError,
          "Length of segment #{from.name} unknown"
      end
      from_l = from.length.to_lastpos
      return [from_l - overlap.length_on_reference, from_l]
    else
      return [0, overlap.length_on_reference]
    end
  end

  # GFA2 positions of the alignment on the +to+ segment
  # @!macro coords
  def to_coords
    if overlap.kind_of?(RGFA::Placeholder)
      raise RGFA::ValueError,
        "Link: #{self.to_s}\n"+
        "Missing overlap, cannot compute overlap coordinates"
    end
    if to_orient == :+
      return [0, overlap.length_on_query]
    else
      if !to.kind_of?(RGFA::Line)
        raise RGFA::RuntimeError,
          "Line not embedded in a RGFA object"
      end
      if to.length.nil?
        raise RGFA::ValueError,
          "Length of segment #{to.name} unknown"
      end
      to_l = to.length.to_lastpos
      return [to_l - overlap.length_on_query, to_l]
    end
  end

end
