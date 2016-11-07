#
# Methods for the RGFA class, which allow to handle custom records.
#
module RGFA::Lines::CustomRecords

  # All custom lines of the graph
  # @return [Array<RGFA::Line::Comment>]
  def custom_records
    cr = {}
    (@records.keys - [:H, :C, :L, :"#", :F, :E, :G, :O, :U, :S, :P]).each do |k|
      cr[k] = @records[k]
    end
    cr.freeze
  end

end
