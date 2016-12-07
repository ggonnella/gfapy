# A path line of a GFA1 file
#
class RGFA::Line::Group::Path < RGFA::Line::Group

  RECORD_TYPE = :P
  POSFIELDS = [:path_name, :segment_names, :overlaps]
  PREDEFINED_TAGS = []
  FIELD_ALIAS = { :name => :path_name }
  DATATYPE = {
    :path_name => :path_name_gfa1,
    :segment_names => :oriented_identifier_list_gfa1,
    :overlaps => :alignment_list_gfa1,
  }
  REFERENCE_FIELDS = [:segment_names, :overlaps]
  BACKREFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = []
  OTHER_REFERENCES = [:links]

  apply_definitions

  alias_method :to_sym, :path_name

end

require_relative "path/topology"
require_relative "path/references"
require_relative "path/validation"
require_relative "path/captured_path"

class RGFA::Line::Group::Path
  include RGFA::Line::Group::Path::Topology
  include RGFA::Line::Group::Path::References
  include RGFA::Line::Group::Path::Validation
  include RGFA::Line::Group::Path::CapturedPath
end
