module RGFA::Line::Segment::References

  # References to the graph lines which involve the segment as dovetail overlap
  # @param extremity [:L,:R, nil] left of right extremity of the segment
  #   (default: both)
  # @return [Array<RGFA::Line>] an array of lines; the lines themselves can be
  #   modified, but the array is frozen
  # @note to add a dovetail overlap, create a L (GFA1) or E (GFA2) line and
  #   connect it to the graph; to remove a dovetail overlap, call
  #   RGFA::Line#disconnect on the corresponding L or E line
  def dovetails(extremity = nil)
    if extremity
      send(:"dovetails_#{extremity}")
    else
      dovetails_L + dovetails_R
    end
  end

  # References to the graph lines which involve the segment as dovetail overlap
  # @param extremity [:L,:R, nil] left of right extremity of the segment
  #   (default: both)
  def gaps(extremity = nil)
    if extremity
      send(:"gaps_#{extremity}")
    else
      gaps_L + gaps_R
    end
  end

  # References to graph edges (C lines for GFA1, E for GFA2) which involve the
  # segment in a containment relationship.
  def containments
    edges_to_contained + edges_to_containers
  end

  # Computes the connectivity of a segment from its number of dovetail overlaps.
  #
  # @return [Array<conn_symbol,conn_symbol>]
  #  conn. symbols respectively of the :L and :R ends of +segment+.
  #
  # <b>Connectivity symbol:</b> (+conn_symbol+)
  # - Let _n_ be the number of links to an end (+:L+ or +:R+) of a segment.
  #   Then the connectivity symbol is +:M+ if <i>n > 1</i>, otherwise _n_.
  #
  def connectivity
    if !connected?
      raise RGFA::ArgumentError,
        "Cannot compute the connectivity of #{self}\n"+
        "Segment is not connected to a RGFA instance"
    end
    connectivity_symbols(dovetails_L.size, dovetails_R.size)
  end

  # List of dovetail-neighbours of a segment
  # @return [Array<RGFA::Line::Segment>] segments connected to the current
  #   segment by dovetail overlap relationships (L lines for GFA1,
  #   dovetail-representing E lines for GFA2)
  def neighbours(extremity = nil)
    dovetails(extremity).map{|l|l.other(self)}.uniq
  end

  # List of segments which contain the segment
  # @return [Array<RGFA::Line::Segment>] segments connected to the current
  #   segment by containment relationships (C lines for GFA1,
  #   containment-representing E lines for GFA2), where the current segment is
  #   the contained segment
  def containers
    edges_to_containers.map(&:from).uniq
  end

  # List of segments which are contained in the segment
  # @return [Array<RGFA::Line::Segment>] segments connected to the current
  #   segment by containment relationships (C lines for GFA1,
  #   containment-representing E lines for GFA2), where the current segment is
  #   the container segment
  def contained
    edges_to_contained.map(&:to).uniq
  end

  private

  def connectivity_symbols(n,m)
    [connectivity_symbol(n), connectivity_symbol(m)]
  end

  def connectivity_symbol(n)
    n > 1 ? :M : n
  end

  def backreference_keys(ref, key_in_ref)
    case ref.record_type
    when :E
      [:dovetails_L, :dovetails_R, :internals,
       :edges_to_containers, :edges_to_contained]
    when :L
      [:dovetails_L, :dovetails_R]
    when :C
      (key_in_ref == :from) ? [:edges_to_contained] : [:edges_to_containers]
    when :G
      [:gaps_L, :gaps_R]
    when :F
      [:fragments]
    when :O, :P
      [:paths]
    when :U
      [:subgraphs]
    else
      []
    end
  end

end
