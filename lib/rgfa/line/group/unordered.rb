# An unordered group line of a GFA2 file
class RGFA::Line::Group::Unordered < RGFA::Line::Group

  RECORD_TYPE = :U
  POSFIELDS = [:pid, :items]
  PREDEFINED_TAGS = []
  FIELD_ALIAS = {}
  DATATYPE = {
    :pid => :optional_identifier_gfa2,
    :items => :identifier_list_gfa2,
  }
  NAME_FIELD = :pid
  STORAGE_KEY = :name
  REFERENCE_FIELDS = [:items]
  BACKREFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = [:sets]
  OTHER_REFERENCES = []

  apply_definitions

  alias_method :to_sym, :pid

end

require_relative "gfa2/references"
require_relative "gfa2/same_id"
require_relative "unordered/references"
require_relative "unordered/induced_set"

class RGFA::Line::Group::Unordered
  include RGFA::Line::Group::GFA2::References
  include RGFA::Line::Group::GFA2::SameID
  include RGFA::Line::Group::Unordered::References
  include RGFA::Line::Group::Unordered::InducedSet
end
