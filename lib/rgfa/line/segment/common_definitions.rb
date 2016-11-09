module RGFA::Line::Segment::CommonDefinitions

  RECORD_TYPE = :S
  REFERENCE_FIELDS = []
  DEPENDENT_REFERENCES = [:dovetails_L, :dovetails_R, :gaps_L, :gaps_R,
                          :contained, :containers, :fragments,
                          :unordered_groups, :ordered_groups]
                          # some are always empty in GFA1 but still here
                          # so that the interface remains compatible with GFA2
  NONDEPENDENT_REFERENCES = [:paths]

end
