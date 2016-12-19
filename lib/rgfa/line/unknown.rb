# A GFA2 line which was referred to only by G or O lines
# and has not been found yet (ie is always virtual)
# @tested_in api_positionals, unit_unknown, api_references
class RGFA::Line::Unknown < RGFA::Line

  RECORD_TYPE = nil
  POSFIELDS = [:name]
  FIELD_ALIAS = { }
  PREDEFINED_TAGS = []
  DATATYPE = {
    :name => :identifier_gfa2,
  }
  REFERENCE_FIELDS = []
  NAME_FIELD = :name
  STORAGE_KEY = :name
  BACKREFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = [:sets, :paths]
  OTHER_REFERENCES = []

  apply_definitions

  alias_method :to_sym, :name
end

require_relative "unknown/writer.rb"
require_relative "unknown/virtual.rb"

class RGFA::Line::Unknown
  include RGFA::Line::Unknown::Writer
  include RGFA::Line::Unknown::Virtual
end
