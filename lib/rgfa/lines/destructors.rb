#
# Methods for the RGFA class, which allow to remove lines.
#
module RGFA::Lines::Destructors

  # Delete a line from the RGFA graph
  #
  # @param line [RGFA::Line, Symbol] a line instance or identifier
  #
  # @tested_in api_lines_destructors
  #
  # @return [RGFA] self
  def rm(gfa_line, *args)
    line!(gfa_line).disconnect
    return self
  end

  # Remove all links of a segment end end except that to the other specified
  # segment end.
  #
  # @param segment_end [RGFA::SegmentEnd] the segment end
  # @param other_end [RGFA::SegmentEnd] the other segment end
  # @param conserve_components [Boolean] <i>(defaults to: +false+)</i>
  #   Do not remove links if removing them breaks the graph into unconnected
  #   components.
  #
  # @tested_in XXX
  #
  # @return [RGFA] self
  def delete_other_links(segment_end, other_end, conserve_components: false)
    segment_end = segment_end.to_segment_end
    other_end = other_end.to_segment_end
    s = segment!(segment_end.segment)
    s.dovetails(segment_end.end_type).each do |l|
      if l.other_end(segment_end) != other_end
        if !conserve_components or !cut_link?(l)
          l.disconnect
        end
      end
    end
  end

  # @api private
  module API_PRIVATE

    # Remove a line from the @records collection in which it was registered
    # @tested_in test_unit_rgfa_lines
    # @return [void]
    def unregister_line(gfa_line)
      api_private_check_gfa_line(gfa_line, "unregister_line")
      if gfa_line.record_type == :H
        raise RGFA::AssertionError, "Bug found, please report\n"+
          "gfa_line: #{gfa_line}"
      end
      collection = @records[gfa_line.record_type]
      key = gfa_line
      delete_if_empty = nil
      if collection.kind_of?(Hash)
        storage_key = gfa_line.class::STORAGE_KEY
        case storage_key
        when :name
          if !gfa_line.name.empty?
            key = gfa_line.name
          else
            collection = collection[nil]
          end
        when :external
          collection = collection[gfa_line.external.name]
          delete_if_empty = gfa_line.external.name
        end
      end
      collection.delete(key)
      if delete_if_empty and collection.empty?
        @records[gfa_line.record_type].delete(delete_if_empty)
      end
    end

  end
  include API_PRIVATE

end
