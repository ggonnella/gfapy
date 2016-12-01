# An unordered group line of a GFA2 file
class RGFA::Line::Group::Unordered < RGFA::Line::Group

  RECORD_TYPE = :U
  POSFIELDS = [:pid, :items]
  PREDEFINED_TAGS = []
  FIELD_ALIAS = {:name => :pid}
  DATATYPE = {
    :pid => :optional_identifier_gfa2,
    :items => :identifier_list_gfa2,
  }
  REFERENCE_FIELDS = [:items]
  REFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = [:unordered_groups]
  OTHER_REFERENCES = []

  define_field_methods

  alias_method :to_sym, :pid

end

require_relative "gfa2/references"
require_relative "unordered/references"
require_relative "unordered/induced_set"

class RGFA::Line::Group::Unordered
  include RGFA::Line::Group::GFA2::References
  include RGFA::Line::Group::Unordered::References
  include RGFA::Line::Group::Unordered::InducedSet
end
