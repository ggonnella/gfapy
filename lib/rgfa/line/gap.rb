# A gap line of a GFA2 file
class RGFA::Line::Gap < RGFA::Line

  RECORD_TYPE = :G
  POSFIELDS = [:gid, :sid1, :d1, :d2, :sid2, :disp, :var]
  REFERENCE_FIELDS = [:sid1, :d1, :d2, :sid2]
  FIELD_ALIAS = {:id => :gid}
  PREDEFINED_TAGS = []
  DATATYPE = {
    :gid => :optional_identifier_gfa2,
    :sid1 => :identifier_gfa2,
    :d1 => :gap_direction,
    :d2 => :gap_direction,
    :sid2 => :identifier_gfa2,
    :disp => :i,
    :var => :optional_integer
  }
  DEPENDENT_REFERENCES = [:paths, :subgraphs]
  NONDEPENDENT_REFERENCES = []

  define_field_methods!

end

require_relative "gap/references.rb"

class RGFA::Line::Gap
  include RGFA::Line::Gap::References
end
