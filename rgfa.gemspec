Gem::Specification.new do |s|
  s.name = 'rgfa'
  s.version = '1.3.1'
  s.date = '2016-09-26'
  s.summary = 'Parse, edit and write GFA-format graphs in Ruby'
  s.description = <<-EOF
    The Graphical Fragment Assembly (GFA) is a proposed format which allow
    to describe the product of sequence assembly.
    This gem implements the proposed specifications for the GFA format
    described under https://github.com/pmelsted/GFA-spec/blob/master/GFA-spec.md
    as close as possible.
    The library allows to create an RGFA object from a file in the GFA format
    or from scratch, to enumerate the graph elements (segments, links,
    containments, paths and header lines), to traverse the graph (by
    traversing all links outgoing from or incoming to a segment), to search for
    elements (e.g. which links connect two segments) and to manipulate the
    graph (e.g. to eliminate a link or a segment or to duplicate a segment
    distributing the read counts evenly on the copies).
  EOF
  s.author = 'Giorgio Gonnella'
  s.email = 'gonnella@zbh.uni-hamburg.de'
  s.files = %w[
lib/rgfatools.rb
lib/rgfatools/artifacts.rb
lib/rgfatools/p_bubbles.rb
lib/rgfatools/multiplication.rb
lib/rgfatools/copy_number.rb
lib/rgfatools/superfluous_links.rb
lib/rgfatools/linear_paths.rb
lib/rgfatools/invertible_segments.rb
lib/rgfa.rb
lib/rgfa/lastpos.rb
lib/rgfa/field.rb
lib/rgfa/logger.rb
lib/rgfa/segment_ends_path.rb
lib/rgfa/graph_operations/connectivity.rb
lib/rgfa/graph_operations/multiplication.rb
lib/rgfa/graph_operations/linear_paths.rb
lib/rgfa/graph_operations/rgl.rb
lib/rgfa/error.rb
lib/rgfa/segment_end.rb
lib/rgfa/field/position_gfa1.rb
lib/rgfa/field/alignment_gfa1.rb
lib/rgfa/field/path_name_gfa1.rb
lib/rgfa/field/orientation.rb
lib/rgfa/field/string.rb
lib/rgfa/field/segment_name_gfa1.rb
lib/rgfa/field/float.rb
lib/rgfa/field/json.rb
lib/rgfa/field/identifier_gfa2.rb
lib/rgfa/field/position_gfa2.rb
lib/rgfa/field/integer.rb
lib/rgfa/field/char.rb
lib/rgfa/field/sequence_gfa2.rb
lib/rgfa/field/generic.rb
lib/rgfa/field/alignment_gfa2.rb
lib/rgfa/field/alignment_list_gfa1.rb
lib/rgfa/field/comment.rb
lib/rgfa/field/numeric_array.rb
lib/rgfa/field/optional_identifier_gfa2.rb
lib/rgfa/field/identifier_list_gfa2.rb
lib/rgfa/field/oriented_identifier_gfa2.rb
lib/rgfa/field/byte_array.rb
lib/rgfa/field/sequence_gfa1.rb
lib/rgfa/field/oriented_identifier_list_gfa1.rb
lib/rgfa/field/custom_record_type.rb
lib/rgfa/field/oriented_identifier_list_gfa2.rb
lib/rgfa/field/optional_integer.rb
lib/rgfa/symbol_invert.rb
lib/rgfa/alignment/trace.rb
lib/rgfa/alignment/cigar.rb
lib/rgfa/alignment/placeholder.rb
lib/rgfa/oriented_line.rb
lib/rgfa/line/fragment/references.rb
lib/rgfa/line/header.rb
lib/rgfa/line/fragment.rb
lib/rgfa/line/gap.rb
lib/rgfa/line/group/ordered.rb
lib/rgfa/line/group/unordered.rb
lib/rgfa/line/group/unordered/references.rb
lib/rgfa/line/group/unordered/induced_set.rb
lib/rgfa/line/group/gfa2/references.rb
lib/rgfa/line/group/gfa2/same_id.rb
lib/rgfa/line/group/path/topology.rb
lib/rgfa/line/group/path/references.rb
lib/rgfa/line/group/path/validation.rb
lib/rgfa/line/group/ordered/references.rb
lib/rgfa/line/group/ordered/induced_set.rb
lib/rgfa/line/group/path.rb
lib/rgfa/line/group.rb
lib/rgfa/line/edge/containment/to_gfa2.rb
lib/rgfa/line/edge/containment/canonical.rb
lib/rgfa/line/edge/containment/pos.rb
lib/rgfa/line/edge/gfa2.rb
lib/rgfa/line/edge/containment.rb
lib/rgfa/line/edge/gfa1/to_gfa2.rb
lib/rgfa/line/edge/gfa1/references.rb
lib/rgfa/line/edge/gfa1/alignment_type.rb
lib/rgfa/line/edge/gfa1/other.rb
lib/rgfa/line/edge/gfa1/oriented_segments.rb
lib/rgfa/line/edge/link.rb
lib/rgfa/line/edge/link/equivalence.rb
lib/rgfa/line/edge/link/to_gfa2.rb
lib/rgfa/line/edge/link/references.rb
lib/rgfa/line/edge/link/canonical.rb
lib/rgfa/line/edge/link/complement.rb
lib/rgfa/line/edge/gfa2/references.rb
lib/rgfa/line/edge/gfa2/to_gfa1.rb
lib/rgfa/line/edge/gfa2/alignment_type.rb
lib/rgfa/line/edge/gfa2/other.rb
lib/rgfa/line/edge/common/from_to.rb
lib/rgfa/line/edge/common/alignment_type.rb
lib/rgfa/line/gap/references.rb
lib/rgfa/line/custom_record/init.rb
lib/rgfa/line/custom_record.rb
lib/rgfa/line/edge.rb
lib/rgfa/line/segment/factory.rb
lib/rgfa/line/segment/writer_wo_sequence.rb
lib/rgfa/line/segment/gfa2.rb
lib/rgfa/line/segment/gfa2_to_gfa1.rb
lib/rgfa/line/segment/length_gfa1.rb
lib/rgfa/line/segment/gfa1.rb
lib/rgfa/line/segment/references.rb
lib/rgfa/line/segment/gfa1_to_gfa2.rb
lib/rgfa/line/segment/coverage.rb
lib/rgfa/line/comment.rb
lib/rgfa/line/segment.rb
lib/rgfa/line/unknown.rb
lib/rgfa/line/common/version_conversion.rb
lib/rgfa/line/common/virtual_to_real.rb
lib/rgfa/line/common/connection.rb
lib/rgfa/line/common/equivalence.rb
lib/rgfa/line/common/cloning.rb
lib/rgfa/line/common/field_data.rb
lib/rgfa/line/common/dynamic_fields.rb
lib/rgfa/line/common/init.rb
lib/rgfa/line/common/field_datatype.rb
lib/rgfa/line/common/disconnection.rb
lib/rgfa/line/common/update_references.rb
lib/rgfa/line/common/writer.rb
lib/rgfa/line/common/validate.rb
lib/rgfa/line/header/version_conversion.rb
lib/rgfa/line/header/connection.rb
lib/rgfa/line/header/multiline.rb
lib/rgfa/line/comment/tags.rb
lib/rgfa/line/comment/init.rb
lib/rgfa/line/comment/writer.rb
lib/rgfa/sequence.rb
lib/rgfa/numeric_array.rb
lib/rgfa/byte_array.rb
lib/rgfa/lines.rb
lib/rgfa/alignment.rb
lib/rgfa/placeholder.rb
lib/rgfa/line.rb
lib/rgfa/lines/finders.rb
lib/rgfa/lines/destructors.rb
lib/rgfa/lines/creators.rb
lib/rgfa/lines/headers.rb
lib/rgfa/lines/collections.rb
lib/rgfa/field_array.rb
lib/rgfa/graph_operations.rb
bin/rgfa-mergelinear
bin/rgfa-findcrisprs
bin/gfadiff
bin/rgfa-simdebruijn
            ]
  s.homepage = 'http://github.com/ggonnella/rgfa'
  s.license = 'CC-BY-SA'
  s.required_ruby_version = '>= 2.0'
end
