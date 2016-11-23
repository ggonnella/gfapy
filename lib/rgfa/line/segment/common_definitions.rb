module RGFA::Line::Segment::CommonDefinitions

  RECORD_TYPE = :S
  REFERENCE_FIELDS = []
  REFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = [:dovetails_L, :dovetails_R, :gaps_L, :gaps_R,
                     :edges_to_contained, :edges_to_containers,
                     :fragments, :internals, :unordered_groups, :ordered_groups]
  OTHER_REFERENCES = [:paths]

end
