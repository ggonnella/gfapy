#
# Methods for the RGFA class, which allow to handle custom records.
#
module RGFA::Lines::CustomRecords

  def add_custom_record(gfa_line)
    gfa_line = gfa_line.to_rgfa_line(validate: @validate)
    @custom_records[gfa_line.record_type] ||= []
    @custom_records[gfa_line.record_type] << gfa_line
  end
  protected :add_custom_record

  # Delete a custom line from the RGFA object
  # @return [RGFA] self
  # @param gfa_line [RGFA::Line::CustomRecord] custom line instance
  def delete_custom_record(gfa_line)
    gfa_line = gfa_line.to_rgfa_line
    @custom_records[gfa_line.record_type].delete(gfa_line)
    return self
  end

  # All custom lines of the graph
  # @return [Array<RGFA::Line::Comment>]
  def custom_records
    @custom_records
  end

end
