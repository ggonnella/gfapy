# A segment or segment name plus an additional boolean attribute
#
# This class shall not be initialized directly.
#
class GFA::SegmentInfo < Array

  # Check that the elements of the array are compatible with the definition.
  #
  # @!macro[new] segment_info_validation_errors
  #   @raise [ArgumentError] if size is not 2
  #   @raise [GFA::SegmentInfo::InvalidAttribute] if second element
  #     is not a valid info
  # @return [void]
  def validate!
    if size != 2
      raise ArgumentError, "Wrong n of elements, 2 expected (#{inspect})"
    end
    if !self.class::ATTR.include?(self[1])
      raise GFA::SegmentInfo::InvalidAttribute,
        "Invalid attribute (#{self[1].inspect})"
    end
    return nil
  end

  # @return [String, GFA::Line::Segment] the segment instance or name
  def segment
    self[0]
  end

  # @return [String] the segment name
  def name
    self[0].kind_of?(GFA::Line::Segment) ? self[0].name : self[0]
  end

  def attribute
    self[1]
  end

  # @return [GFA::SegmentInfo] same segment, inverted attribute
  def other
    self.class.new([self[0],
                    self.class::ATTR[self.class::ATTR[0] == self[1] ? 1 : 0]])
  end

  # @param [Object] attribute an attribute value
  # @return [Object] the other attribute value
  def self.other(attribute)
    i = self::ATTR.index(attribute)
    if i.nil?
      raise GFA::SegmentInfo::InvalidAttribute,
        "Invalid attribute (#{self[1].inspect})"
    end
    return self::ATTR[i-1]
  end

  # @return [String] name of the segment and attribute
  def to_s
    "#{name}:#{attribute}"
  end

  # @return [Symbol] name of the segment and attribute
  def to_sym
    to_s.to_sym
  end

  # Compare the segment names and attributes of two instances
  #
  # @param [GFA::SegmentInfo] other the other instance
  # @return [Boolean]
  def ==(other)
    other = other.to_segment_info(self.class)
    (self.name == other.name) and
      (self.attribute == other.attribute)
  end

end

# Error raised if an unknown value for attribute is used
class GFA::SegmentInfo::InvalidAttribute < ArgumentError; end

# A representation of a segment end
class GFA::SegmentEnd < GFA::SegmentInfo
  # Segment end type (begin or end)
  ATTR = [ END_TYPE_BEGIN = :B, END_TYPE_END = :E ]
  alias_method :end_type, :attribute
  alias_method :other_end, :other
end

# A segment plus orientation
class GFA::OrientedSegment < GFA::SegmentInfo
  # Segment orientation
  ATTR = [ ORIENT_FWD = "+", ORIENT_REV = "-" ]
  alias_method :orient, :attribute
  alias_method :other_orient, :other
end

class Array

  # Create and validate a segment end from an array
  # @!macro segment_info_validation_errors
  # @return [GFA::SegmentEnd]
  def to_segment_end
    to_segment_info(GFA::SegmentEnd)
  end

  # Create and validate a segment end from an array
  # @!macro segment_info_validation_errors
  # @return [GFA::OrientedSegment]
  def to_oriented_segment
    to_segment_info(GFA::OrientedSegment)
  end

  protected

  def to_segment_info(subclass)
    return self if self.kind_of?(subclass)
    se = subclass.new(self)
    se.validate!
    return se
  end

end
