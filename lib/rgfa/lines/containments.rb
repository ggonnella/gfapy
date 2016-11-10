#
# Methods for the RGFA class, which allow to handle containments in the graph.
#
module RGFA::Lines::Containments

  # All containments in the graph
  # @return [Array<RGFA::Line::Edge::Containment>]
  def containments
    @records[:C]
  end

  # Searches all containments of +contained+ in +container+.
  # Returns a possibly empty array of containments.
  #
  # @return [Array<RGFA::Line::Edge::Containment>]
  # @!macro [new] container_contained
  #   @param container [RGFA::Line::Segment::GFA1, Symbol]
  #     a segment instance or name
  #   @param contained [RGFA::Line::Segment::GFA1, Symbol]
  #     a segment instance or name
  #
  def containments_between(container, contained)
    segment!(container).contained.select {|l| l.to.to_sym == contained.to_sym }
  end

end
