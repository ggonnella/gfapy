# A representation of a segment end
#
class GFA::SegmentEnd < Array

  # Type of segment end (begin or end)
  TYPE = [ END_TYPE_BEGIN = :B, END_TYPE_END = :E ]

  # Check that the elements of the array are compatible
  # with the definion of a segment end.
  #
  # @raise [ArgumentError] if size is not 2
  # @raise [GFA::SegmentEnd::UnknownType] if second element
  #   is not a valid end type
  # @return [void]
  def validate!
    if size != 2
      raise ArgumentError, "Wrong number of elements in SegmentEnd"
    end
    if !GFA::SegmenEnd::TYPE.include?(self[1])
      raise GFA::SegmentEnd::UnknownType,
        "Unknown end type (#{self[1].inspect})"
    end
    return nil
  end

  # @return [String] the segment name
  def name
    self[0].kind_of?(GFA::Line::Segment) ? self[0].name : self[0]
  end

  # @return [GFA::SegmentEnd::TYPE] the end type
  def end_type
    self[1]
  end

  # @return [GFA::SegmentEnd] the other end of segment
  def other_end
    self[0] + self.other_end_type(self[1])
  end

  # @param [GFA::SegmentEnd::TYPE] end_type an end type
  # @return [GFA::SegmentEnd::TYPE] the other end type
  def self.other_end_type(end_type)
    i = GFA::SegmentEnd::TYPE.index(end_type)
    if i.nil?
      raise GFA::SegmentEnd::UnknownType,
        "Unknown end type (#{end_type.inspect})"
    end
    return GFA::SegmentEnd::TYPE[i-1]
  end
end

# Error raised if an unknown value for segment end type is given
class GFA::SegmentEnd::UnknownType < ArgumentError; end

module Kernel

  # Create and validate a segment end from an array
  # @return [GFA::SegmentEnd]
  # @param array [Array(String,GFA::SegmentEnd::TYPE)]
  def SegmentEnd(array)
    se = GFA::SegmentEnd.new(array.to_a)
    se.validate!
    return se
  end
end
