# A path line of a GFA1 file
#
# @note The field names are derived from the RGFA specification at:
#   https://github.com/pmelsted/RGFA-spec/blob/master/RGFA-spec.md#path-line
#   and were made all downcase with _ separating words
#
class RGFA::Line::Path < RGFA::Line

  RECORD_TYPE = :P
  POSFIELDS = [:path_name, :segment_names, :overlaps]
  REFERENCE_FIELDS = [:segment_names, :overlaps]
  PREDEFINED_TAGS = []
  FIELD_ALIAS = {:id => :path_name}
  DATATYPE = {
    :path_name => :path_name_gfa1,
    :segment_names => :oriented_segments,
    :overlaps => :alignment_list_gfa1,
  }

  define_field_methods!

  alias_method :to_sym, :path_name

end

require_relative "path/topology"
require_relative "path/references"
require_relative "path/validation"

class RGFA::Line::Path
  include RGFA::Line::Path::Topology
  include RGFA::Line::Path::References
  include RGFA::Line::Path::Validation
end
