# An ordered group line of a GFA2 file
class RGFA::Line::Group::Ordered < RGFA::Line::Group

  RECORD_TYPE = :O
  POSFIELDS = [:pid, :items]
  PREDEFINED_TAGS = []
  FIELD_ALIAS = { :name => :pid }
  DATATYPE = {
    :pid => :optional_identifier_gfa2,
    :items => :oriented_identifier_list_gfa2,
  }
  REFERENCE_FIELDS = [:items]
  REFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = [:paths, :sets]
  OTHER_REFERENCES = []

  define_field_methods

  alias_method :to_sym, :pid

end

require_relative "gfa2/references"
require_relative "gfa2/same_id"
require_relative "ordered/references"
require_relative "ordered/captured_path"

class RGFA::Line::Group::Ordered
  include RGFA::Line::Group::GFA2::References
  include RGFA::Line::Group::GFA2::SameID
  include RGFA::Line::Group::Ordered::References
  include RGFA::Line::Group::Ordered::CapturedPath
end
