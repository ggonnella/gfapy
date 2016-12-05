require_relative "error"

# A segment or segment name and an end symbol (:L or :R)
#
class RGFA::SegmentEnd < Array

  def initialize(segment, end_type)
    self[0]=segment
    self[1]=end_type
  end

  # Check that the elements of the array are compatible with the definition.
  #
  # @!macro [new] segment_info_validation_errors
  #   @raise [RGFA::ValueError] if size is not 2
  #   @raise [RGFA::ValueError] if second element
  #     is not a valid info
  # @return [void]
  def validate
    if ![:L, :R].include?(end_type)
      raise RGFA::ValueError,
        "Invalid end type (#{end_type.inspect})"
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

  # @return [Symbol] the end type
  def end_type
    self[1]
  end

  # Set the end type
  # @param value [Symbol] the end type
  # @return [Symbol] +value+
  def end_type=(value)
    self[1]=(value)
  end

  # @return [Symbol] the segment name
  def name
    segment.to_sym
  end

  # @return [RGFA::SegmentInfo] same segment, inverted end type
  def invert
    self.class.new(self.segment, self.end_type.invert)
  end

  # @return [String] name of the segment and end type
  def to_s
    "#{name}#{end_type}"
  end

  # @return [Symbol] name of the segment and end type
  def to_sym
    to_s.to_sym
  end

  # Compare the segment names and end types of two instances
  #
  # @param [RGFA::SegmentInfo] other the other instance
  # @return [Boolean]
  def ==(other)
    to_s == other.to_segment_end.to_s
  end

  # Compare the segment names and end types of two instances
  #
  # @param [RGFA::SegmentInfo] other the other instance
  # @return [Boolean]
  def <=>(other)
    to_s <=> other.to_segment_end.to_s
  end

  def to_segment_end
    self
  end

  (Array.instance_methods - Object.instance_methods).each do |method|
    private method
  end

  def to_a
    [segment, end_type]
  end
  public :to_a

end

class Array

  # Create and validate a segment end from an array
  # @!macro segment_info_validation_errors
  # @return [RGFA::SegmentEnd]
  def to_segment_end
    if self.size != 2
      raise RGFA::ValueError,
        "Wrong n of elements, 2 expected (#{inspect})"
    end
    se = RGFA::SegmentEnd.new(*map {|e| e.kind_of?(String) ? e.to_sym : e})
    se.validate
    return se
  end

end

# An array containing {RGFA::SegmentEnd} elements, which defines a path
# in the graph
class RGFA::SegmentEndsPath < Array
  # Create a reverse direction path
  # @return [RGFA::SegmentEndsPath]
  def reverse
    super.map {|segment_end| segment_end.to_segment_end.invert}
  end
end
