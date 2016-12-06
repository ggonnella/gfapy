# A fragment line of a GFA2 file
class RGFA::Line::Fragment < RGFA::Line

  RECORD_TYPE = :F
  POSFIELDS = [:sid, :external, :s_beg, :s_end, :f_beg, :f_end, :alignment]
  FIELD_ALIAS = {}
  PREDEFINED_TAGS = []
  DATATYPE = {
    :sid => :identifier_gfa2,
    :external => :oriented_identifier_gfa2,
    :s_beg => :position_gfa2,
    :s_end => :position_gfa2,
    :f_beg => :position_gfa2,
    :f_end => :position_gfa2,
    :alignment => :alignment_gfa2
  }
  REFERENCE_FIELDS = [:sid]
  BACKREFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = []
  OTHER_REFERENCES = []

  define_field_methods

end

require_relative "fragment/references.rb"

class RGFA::Line::Fragment
  include RGFA::Line::Fragment::References
end
