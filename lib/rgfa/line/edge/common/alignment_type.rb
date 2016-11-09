RGFA::Line::Edge::Common ||= Module.new

#
# Requirements: +alignment_type+
#
module RGFA::Line::Edge::Common::AlignmentType

  # @return [Boolean] does the line represent an internal
  #   overlap (GFA2 edge, not representable in GFA1)?
  def internal?
    alignment_type == :I
  end

  # @return [Boolean] does the line represent a containment
  #   (GFA1 containment or GFA2 edge equivalent to a GFA1 containment)?
  def containment?
    alignment_type == :C
  end

  # @return [Boolean] does the line represent a dovetail overlap?
  #   (GFA1 link or GFA2 edge equivalent to a GFA1 link)?
  def link?
    alignment_type == :L
  end

end
