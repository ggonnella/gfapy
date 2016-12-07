require_relative "../lib/rgfa.rb"
require_relative "./extension"

class RGFA::Line::Segment::GFA2
  DEPENDENT_LINES.delete(:metagenomic_assignments)
  undef :metagenomic_asssignments
end

class RGFA::Line
  class << self
    undef :subclass
    def subclass(record_type, version: nil)
      orig_subclass(record_type, version: version)
    end
  end
  RECORD_TYPE_VERSIONS[:specific][:gfa2].delete(:M)
  RECORD_TYPE_VERSIONS[:specific][:gfa2].delete(:T)
end

RGFA::RECORDS_WITH_NAME.delete(:M)
RGFA::RECORDS_WITH_NAME.delete(:T)

RGFA::Field::GFA2_POSFIELD_DATATYPE.delete(:taxon_id)
