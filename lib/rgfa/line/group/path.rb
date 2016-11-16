# A path line of a GFA1 file
#
class RGFA::Line::Group::Path < RGFA::Line::Group

  RECORD_TYPE = :P
  POSFIELDS = [:path_name, :segment_names, :overlaps]
  PREDEFINED_TAGS = []
  FIELD_ALIAS = { :name => :path_name }
  DATATYPE = {
    :path_name => :path_name_gfa1,
    :segment_names => :oriented_segments,
    :overlaps => :alignment_list_gfa1,
  }
  REFERENCE_FIELDS = [:segment_names, :overlaps]
  REFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = []
  OTHER_REFERENCES = [:links, :segments]

  define_field_methods!

  alias_method :to_sym, :path_name

end

require_relative "path/topology"
require_relative "path/references"
require_relative "path/validation"

class RGFA::Line::Group::Path
  include RGFA::Line::Group::Path::Topology
  include RGFA::Line::Group::Path::References
  include RGFA::Line::Group::Path::Validation
end
