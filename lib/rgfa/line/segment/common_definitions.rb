module RGFA::Line::Segment::CommonDefinitions

  RECORD_TYPE = :S
  REFERENCE_FIELDS = []
  REFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = [:dovetails_L, :dovetails_R, :gaps_L, :gaps_R,
                     :contained, :containers, :fragments,
                     :unordered_groups, :ordered_groups]
  OTHER_REFERENCES = [:paths]

end
