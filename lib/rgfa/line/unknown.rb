# A GFA2 line which was referred to only by G or O lines
# and has not been found yet (ie is always virtual)
class RGFA::Line::Unknown < RGFA::Line

  RECORD_TYPE = nil
  POSFIELDS = [:name]
  FIELD_ALIAS = { }
  PREDEFINED_TAGS = []
  DATATYPE = {
    :name => :identifier_gfa2,
  }
  REFERENCE_FIELDS = []
  DEPENDENT_REFERENCES = [:unordered_groups, :ordered_groups]
  NONDEPENDENT_REFERENCES = []

  define_field_methods!

  alias_method :to_sym, :name

  def virtual?
    true
  end

end
