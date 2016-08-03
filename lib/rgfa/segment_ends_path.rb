class RGFA::SegmentEndsPath < Array
  def reverse
    super.map {|segment_end| segment_end.to_segment_end.invert_end_type}
  end
end
