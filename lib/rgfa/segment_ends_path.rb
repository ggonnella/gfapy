# An array containing {RGFA::SegmentEnd} elements, which defines a path
# in the graph
class RGFA::SegmentEndsPath < Array
  # Create a reverse direction path
  # @return [RGFA::SegmentEndsPath]
  def reverse
    super.map {|segment_end| segment_end.to_segment_end.invert_end_type}
  end
end
