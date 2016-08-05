require_relative "error"

# A segment or segment name plus an additional boolean attribute
#
# This class shall not be initialized directly.
# @api private
#
class RGFA::SegmentInfo < Array

  # Check that the elements of the array are compatible with the definition.
  #
  # @!macro [new] segment_info_validation_errors
  #   @raise [RGFA::SegmentInfo::InvalidSizeError] if size is not 2
  #   @raise [RGFA::SegmentInfo::InvalidAttributeError] if second element
  #     is not a valid info
  # @return [void]
  def validate!
    if size != 2
      raise RGFA::SegmentInfo::InvalidSizeError,
        "Wrong n of elements, 2 expected (#{inspect})"
    end
    if !self.class::ATTR.include?(self[1])
      raise RGFA::SegmentInfo::InvalidAttributeError,
        "Invalid attribute (#{self[1].inspect})"
    end
    return nil
  end

  # @return [Symbol, RGFA::Line::Segment] the segment instance or name
  def segment
    self[0]
  end

  # Set the segment
  # @param value [Symbol, RGFA::Line::Segment] the segment instance or name
  # @return Symbol, RGFA::Line::Segment] +value+
  def segment=(value)
    self[0]=value
  end

  # @return [Symbol] the segment name
  def name
    self[0].kind_of?(RGFA::Line::Segment) ? self[0].name : self[0].to_sym
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

  # @return [Symbol] the other possible value of the attribute
  def attribute_inverted
    self.class::ATTR[self.class::ATTR[0] == self[1] ? 1 : 0]
  end

  # @return [RGFA::SegmentInfo] same segment, inverted attribute
  def invert_attribute
    self.class.new([self[0], self.attribute_inverted])
  end

  # @param [Symbol] attribute an attribute value
  # @return [Symbol] the other attribute value
  def self.invert(attribute)
    i = self::ATTR.index(attribute.to_sym)
    if i.nil?
      raise RGFA::SegmentInfo::InvalidAttributeError,
        "Invalid attribute (#{self[1].inspect})"
    end
    return self::ATTR[i-1]
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

end

# Error raised if the size of the array is wrong
class RGFA::SegmentInfo::InvalidSizeError < RGFA::Error; end

# Error raised if an unknown value for attribute is used
class RGFA::SegmentInfo::InvalidAttributeError < RGFA::Error; end

# A representation of a segment end
class RGFA::SegmentEnd < RGFA::SegmentInfo
  # Segment end type (begin or end)
  ATTR = [ END_TYPE_BEGIN = :B, END_TYPE_END = :E ]
  alias_method :end_type, :attribute
  alias_method :end_type=, :attribute=
  alias_method :invert_end_type, :invert_attribute
  alias_method :end_type_inverted, :attribute_inverted
end

# A segment plus orientation
class RGFA::OrientedSegment < RGFA::SegmentInfo
  # Segment orientation
  ATTR = [ ORIENT_FWD = :+, ORIENT_REV = :- ]
  alias_method :orient, :attribute
  alias_method :orient=, :attribute=
  alias_method :invert_orient, :invert_attribute
  alias_method :orient_inverted, :attribute_inverted
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
    # support converting from gfa gem GraphVertex objects:
    if respond_to?(:segment) and respond_to?(:orient)
      return RGFA::OrientedSegment.new([segment.to_sym, orient.to_sym])
    end
    se = subclass.new(map {|e| e.kind_of?(String) ? e.to_sym : e})
    se.validate!
    return se
  end

end
