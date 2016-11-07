#
# Methods for the RGFA class, which allow to handle containments in the graph.
#
module RGFA::Lines::Containments

  # All containments in the graph
  # @return [Array<RGFA::Line::Containment>]
  def containments
    @records[:C]
  end

  # Find containment lines whose +from+ segment name is +segment_name+
  # @!macro segment_or_name
  # @return [Array<RGFA::Line::Containment>]
  def contained_in(s)
    s = segment!(s)
    s.containments[:from][:+] + s.containments[:from][:-]
  end

  # Find containment lines whose +to+ segment name is +segment_name+
  # @return [Array<RGFA::Line::Containment>]
  # @!macro segment_or_name
  def containing(s)
    s = segment!(s)
    s.containments[:to][:+] + s.containments[:to][:-]
  end

  # Searches all containments of +contained+ in +container+.
  # Returns a possibly empty array of containments.
  #
  # @return [Array<RGFA::Line::Containment>]
  # @!macro [new] container_contained
  #   @param container [RGFA::Line::SegmentGFA1, Symbol]
  #     a segment instance or name
  #   @param contained [RGFA::Line::SegmentGFA1, Symbol]
  #     a segment instance or name
  #
  def containments_between(container, contained)
    contained_in(container).select {|l| l.to.to_sym == contained.to_sym }
  end

  # Searches a containment of +contained+ in +container+.
  # Returns the first containment found or nil if none found.
  #
  # @return [RGFA::Line::Containment, nil]
  # @!macro container_contained
  def containment(container, contained)
    contained_in(container).each do |l|
      if l.to.to_sym == contained.to_sym
        return l
      end
    end
    return nil
  end

  # Searches a containment of +contained+ in +container+.
  # Raises an exception if no such containment was found.
  #
  # @return [RGFA::Line::Containment]
  # @raise [RGFA::NotFoundError] if no such containment found
  # @!macro container_contained
  def containment!(container, contained)
    c = containment(container, contained)
    raise RGFA::NotFoundError, "No containment was found" if c.nil?
    c
  end

end
