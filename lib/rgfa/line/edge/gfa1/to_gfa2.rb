RGFA::Line::Edge::GFA1 ||= Module.new

# Methods for the access of / conversion from a GFA1 link/containment
# as / to a GFA2 edge
#
# Requirements: +from+, +from_orient+, +to+, +to_orient+,
#               +from_coords+, +to_coords+.
module RGFA::Line::Edge::GFA1::ToGFA2

  def eid
    i = get(:id)
    if i.nil?
      return RGFA::Placeholder.new
      #i = "#{from_name}#{from_orient} #{to_name}#{to_orient} #{overlap}"
    end
    return i
  end
  alias_method :to_sym, :eid

  def sid1
    oriented_from
  end

  def sid2
    oriented_to
  end

  def beg1
    from_cords[0]
  end

  def end1
    from_cords[1]
  end

  def beg2
    to_coords[1]
  end

  def end2
    to_cords[1]
  end

  def alignment
    overlap
  end

  def to_gfa2_a
    a = ["E"]
    i = get(:id)
    a << (i ? i.to_s : "*")
    a << sid1.to_s
    a << sid2.to_s
    a += from_coords.map(&:to_s)
    a += to_coords.map(&:to_s)
    a << field_to_s(:overlap)
    (tagnames-[:id]).each {|fn| a << field_to_s(fn, tag: true)}
    return a
  end

  private

  def lastpos_of(field)
    if !send(field).kind_of?(RGFA::Line)
      raise RGFA::RuntimeError,
        "Line #{self} is not embedded in a RGFA object"
    end
    l = send(field).length
    if l.nil?
      raise RGFA::ValueError,
        "Length of segment #{to.name} unknown"
    end
    l.to_lastpos
  end

  def check_overlap
    if overlap.kind_of?(RGFA::Placeholder)
      raise RGFA::ValueError,
        "Link: #{self.to_s}\n"+
        "Missing overlap, cannot compute overlap coordinates"
    end
  end

end
