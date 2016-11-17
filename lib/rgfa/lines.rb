require_relative "error"

RGFA::Lines = Module.new

require_relative "lines/headers"
require_relative "lines/collections"
require_relative "lines/creators"
require_relative "lines/destructors"
require_relative "lines/finders"

#
# Methods for the RGFA class, which allow to handle lines of multiple types.
#
module RGFA::Lines

  include RGFA::Lines::Headers
  include RGFA::Lines::Collections
  include RGFA::Lines::Creators
  include RGFA::Lines::Destructors
  include RGFA::Lines::Finders

  GFA1Specific = [
                   RGFA::Line::Edge::Link,
                   RGFA::Line::Edge::Containment,
                   RGFA::Line::Group::Path,
                 ]

  GFA2Specific = [
                   RGFA::Line::CustomRecord,
                   RGFA::Line::Fragment,
                   RGFA::Line::Gap,
                   RGFA::Line::Edge::GFA2,
                   RGFA::Line::Group::Unordered,
                   RGFA::Line::Group::Ordered,
                   RGFA::Line::Unknown,
                  ]

  # Rename a segment or a path
  #
  # @param old_name [String, Symbol] the name of the segment or path to rename
  # @param new_name [String, Symbol] the new name for the segment or path
  #
  # @raise[RGFA::NotUniqueError]
  #   if +new_name+ is already a segment or path name
  # @return [RGFA] self
  def rename(old_name, new_name)
    old_name = old_name.to_sym
    new_name = new_name.to_sym
    l = search_by_name(new_name)
    if l
      raise RGFA::NotUniqueError,
        "#{new_name} is not unique\n"+
        "Matching line: #{l}"
    end
    l = search_by_name(old_name)
    if l.nil?
      raise RGFA::NotFoundError,
        "No line has ID '#{old_name}'"
    end
    l.name = new_name
    @records[l.record_type].delete(old_name)
    @records[l.record_type][new_name] = l
    self
  end

  private

  def api_private_check_gfa_line(gfa_line, callermeth)
    if !gfa_line.kind_of?(RGFA::Line)
      raise RGFA::TypeError,
        "Note: ##{callermeth} is API private, do not call it directly\n"+
        "Error: line class is #{gfa_line.class} and not RGFA::Line"
    elsif gfa_line.rgfa != self
      raise RGFA::RuntimeError,
        "Note: ##{callermeth} is API private, do not call it directly\n"+
        "Error: line.rgfa is "+
        "#{gfa_line.rgfa.class}:#{gfa_line.rgfa.object_id} and not "+
        "RGFA:#{self.object_id}"
    end
  end

end
