require_relative "../lib/rgfa.rb"

class RGFA::Line::Taxon < RGFA::Line

  RECORD_TYPE = :T
  POSFIELDS = [:tid, :desc]
  PREDEFINED_TAGS = [:UL]
  DATATYPE = {
    :tid => :identifier_gfa2,
    :desc => :Z,
    :UL => :Z,
  }
  NAME_FIELD = :tid
  STORAGE_KEY = :name
  FIELD_ALIAS = {}
  REFERENCE_FIELDS = []
  BACKREFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = [:metagenomic_assignments]
  OTHER_REFERENCES = []

  apply_definitions

end

class RGFA::Line::MetagenomicAssignment < RGFA::Line

  RECORD_TYPE = :M
  POSFIELDS = [:mid, :tid, :sid, :score]
  PREDEFINED_TAGS = []
  DATATYPE = {
    :mid => :optional_identifier_gfa2,
    :tid => :identifier_gfa2,
    :sid => :identifier_gfa2,
    :score => :optional_integer,
  }
  NAME_FIELD = :mid
  STORAGE_KEY = :name
  FIELD_ALIAS = {}
  REFERENCE_FIELDS = [:tid, :sid]
  BACKREFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = []
  OTHER_REFERENCES = []

  apply_definitions

end

class RGFA::Line::MetagenomicAssignment

  def initialize_references
    s = @rgfa.segment(sid)
    if s.nil?
      s = RGFA::Line::Segment::GFA2.new([sid.to_s, "1", "*"],
                                        virtual: true, version: :gfa2)
      s.connect(@rgfa)
    end
    set_existing_field(:sid, s, set_reference: true)
    s.add_reference(self, :metagenomic_assignments)

    t = @rgfa.line(tid)
    if t.nil?
      t = RGFA::Line::Taxon.new([tid.to_s, "*"],
                                virtual: true, version: :gfa2)
      t.connect(@rgfa)
    end
    set_existing_field(:tid, t, set_reference: true)
    t.add_reference(self, :metagenomic_assignments)
  end
  private :initialize_references

end

class RGFA::Line::Segment::GFA2
  DEPENDENT_LINES << :metagenomic_assignments
  define_reference_getters
end

class RGFA::Line
  class << self
    alias_method :orig_subclass, :subclass
    def subclass(record_type, version: nil)
      if version.nil? or version == :gfa2
        case record_type.to_sym
        when :M then return RGFA::Line::MetagenomicAssignment
        when :T then return RGFA::Line::Taxon
        end
      end
      orig_subclass(record_type, version: version)
    end
  end
  RECORD_TYPE_VERSIONS[:specific][:gfa2] << :M
  RECORD_TYPE_VERSIONS[:specific][:gfa2] << :T
end

RGFA::RECORDS_WITH_NAME << :T
RGFA::RECORDS_WITH_NAME << :M

module RGFA::Field::TaxonID

  def validate_encoded(string)
    if string !~ /^taxon:(\d+)$/ and string !~ /^[a-zA-Z0-9_]+$/
      raise RGFA::ValueError, "Invalid taxon ID: #{string}"
    end
  end
  module_function :validate_encoded

  def unsafe_decode(string)
    string.to_sym
  end
  module_function :unsafe_decode

  def decode(string)
    validate_encoded(string)
    unsafe_decode(string)
  end
  module_function :decode

  def validate_decoded(object)
    case object
    when RGFA::Line::Taxon
      validate_encoded(object.name.to_s)
    when Symbol
      validate_encoded(object.to_s)
    else
      raise RGFA::TypeError,
        "Invalid type for taxon ID: #{object.inspect}"
    end
  end
  module_function :validate_decoded

  def unsafe_encode(object)
    object = object.name if object.kind_of?(RGFA::Line::Taxon)
    object.to_s
  end
  module_function :unsafe_encode

  def encode(object)
    validate_decoded(object)
    unsafe_encode(object)
  end
  module_function :encode

end

RGFA::Field::GFA2_POSFIELD_DATATYPE << :taxon_id
RGFA::Field::FIELD_MODULE[:taxon_id] = RGFA::Field::TaxonID
RGFA::Line::Taxon::DATATYPE[:tid] = :taxon_id
RGFA::Line::MetagenomicAssignment::DATATYPE[:tid] = :taxon_id
