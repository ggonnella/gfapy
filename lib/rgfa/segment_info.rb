require_relative "error"

# A segment or segment name plus an additional boolean attribute
#
# This class shall not be initialized directly.
# @api private
#
class RGFA::SegmentInfo < Array

  def initialize(segment, attribute)
    self[0]=segment
    self[1]=attribute
  end

  # Check that the elements of the array are compatible with the definition.
  #
  # @!macro [new] segment_info_validation_errors
  #   @raise [RGFA::ValueError] if size is not 2
  #   @raise [RGFA::ValueError] if second element
  #     is not a valid info
  # @return [void]
  def validate
    if !self.class::ATTR.include?(attribute)
      raise RGFA::ValueError,
        "Invalid attribute (#{attribute.inspect})"
    end
    return nil
  end

  # @return [Symbol, RGFA::Line::Segment::GFA1, RGFA::Line::Segment::GFA2]
  #    the segment instance or name
  def segment
    self[0]
  end

  # Set the segment
  # @param value
  #   [Symbol, RGFA::Line::Segment::GFA1, RGFA::Line::Segment::GFA2]
  #   the segment instance or name
  # @return [Symbol, RGFA::Line::Segment::GFA1, RGFA::Line::Segment::GFA2]
  #   +value+
  def segment=(value)
    self[0]=value
  end

  # @return [Symbol] the attribute
  def attribute
    self[1]
  end

  # Set the attribute
  # @param value [Symbol] the attribute
  # @return [Symbol] +value+
  def attribute=(value)
    self[1]=(value)
  end

  # @return [Symbol] the segment name
  def name
    segment.to_sym
  end

  # @return [RGFA::SegmentInfo] same segment, inverted attribute
  def invert
    self.class.new(self.segment, self.attribute.invert)
  end

  # @return [String] name of the segment and attribute
  def to_s
    "#{name}#{attribute}"
  end

  # @return [Symbol] name of the segment and attribute
  def to_sym
    to_s.to_sym
  end

  # Compare the segment names and attributes of two instances
  #
  # @param [RGFA::SegmentInfo] other the other instance
  # @return [Boolean]
  def ==(other)
    to_s == other.to_segment_info(self.class).to_s
  end

  # Compare the segment names and attributes of two instances
  #
  # @param [RGFA::SegmentInfo] other the other instance
  # @return [Boolean]
  def <=>(other)
    to_s <=> other.to_segment_info(self.class).to_s
  end

  def to_segment_info(subklass)
    self
  end

  (Array.instance_methods - Object.instance_methods).each do |method|
    private method
  end

  def to_a
    [segment, attribute]
  end
  public :to_a

end

# A representation of a segment end
class RGFA::SegmentEnd < RGFA::SegmentInfo
  # Segment end type (begin or end)
  ATTR = [ END_TYPE_LEFT = :L, END_TYPE_RIGHT = :R ]
  alias_method :end_type, :attribute
  alias_method :end_type=, :attribute=
  def to_segment_end; self; end
end

# A segment plus orientation
class RGFA::OrientedSegment < RGFA::SegmentInfo
  # Segment orientation
  ATTR = [ ORIENT_FWD = :+, ORIENT_REV = :- ]
  alias_method :orient, :attribute
  alias_method :orient=, :attribute=
  def to_oriented_segment; self; end
end

class Array

  # Create and validate a segment end from an array
  # @!macro segment_info_validation_errors
  # @return [RGFA::SegmentEnd]
  def to_segment_end
    to_segment_info(RGFA::SegmentEnd)
  end

  # Create and validate a segment end from an array
  # @!macro segment_info_validation_errors
  # @return [RGFA::OrientedSegment]
  def to_oriented_segment
    to_segment_info(RGFA::OrientedSegment)
  end

  protected

  def to_segment_info(subclass)
    return self if self.kind_of?(subclass)
    if self.size != 2
      raise RGFA::ValueError,
        "Wrong n of elements, 2 expected (#{inspect})"
    end
    # support converting from gfa gem GraphVertex objects:
    if respond_to?(:segment) and respond_to?(:orient)
      return RGFA::OrientedSegment.new([segment.to_sym, orient.to_sym])
    end
    se = subclass.new(*map {|e| e.kind_of?(String) ? e.to_sym : e})
    se.validate
    return se
  end

end

class Symbol
  def invert
    case self
    when :+ then :-
    when :- then :+
    when :L then :R
    when :R then :L
    when :> then :<
    when :< then :>
    else
      raise RGFA::ValueError,
        "The symbol #{self.inspect} has no inverse."
    end
  end
end
