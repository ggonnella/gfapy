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
  s.files = [
              'lib/rgfa.rb',
              'lib/rgfa/alignment.rb',
              'lib/rgfa/byte_array.rb',
              'lib/rgfa/cigar.rb',
              'lib/rgfa/connectivity.rb',
              'lib/rgfa/containments.rb',
              'lib/rgfa/comments.rb',
              'lib/rgfa/custom_records.rb',
              'lib/rgfa/error.rb',
              'lib/rgfa/field.rb',
              'lib/rgfa/field/alignment_gfa1.rb',
              'lib/rgfa/field/alignment_gfa2.rb',
              'lib/rgfa/field/byte_array.rb',
              'lib/rgfa/field/char.rb',
              'lib/rgfa/field/cigars_list.rb',
              'lib/rgfa/field/comment.rb',
              'lib/rgfa/field/float.rb',
              'lib/rgfa/field/generic.rb',
              'lib/rgfa/field/identifier.rb',
              'lib/rgfa/field/integer.rb',
              'lib/rgfa/field/json.rb',
              'lib/rgfa/field/numeric_array.rb',
              'lib/rgfa/field/optional_identifier.rb',
              'lib/rgfa/field/orientation.rb',
              'lib/rgfa/field/oriented_segments.rb',
              'lib/rgfa/field/position_gfa1.rb',
              'lib/rgfa/field/position_gfa2.rb',
              'lib/rgfa/field/record_type.rb',
              'lib/rgfa/field/segment_name.rb',
              'lib/rgfa/field/sequence_gfa1.rb',
              'lib/rgfa/field/sequence_gfa2.rb',
              'lib/rgfa/field/string.rb',
              'lib/rgfa/field_array.rb',
              'lib/rgfa/field_writer.rb',
              'lib/rgfa/field_parser.rb',
              'lib/rgfa/field_validator.rb',
              'lib/rgfa/headers.rb',
              'lib/rgfa/line/comment.rb',
              'lib/rgfa/line/containment.rb',
              'lib/rgfa/line/custom_record.rb',
              'lib/rgfa/line/header.rb',
              'lib/rgfa/line/link.rb',
              'lib/rgfa/line/path.rb',
              'lib/rgfa/line/segment.rb',
              'lib/rgfa/line.rb',
              'lib/rgfa/edges.rb',
              'lib/rgfa/fragments.rb',
              'lib/rgfa/gaps.rb',
              'lib/rgfa/line/edge.rb',
              'lib/rgfa/line/fragment.rb',
              'lib/rgfa/line/gap.rb',
              'lib/rgfa/line/ordered_group.rb',
              'lib/rgfa/line/unordered_group.rb',
              'lib/rgfa/ordered_groups.rb',
              'lib/rgfa/unordered_groups.rb',
              'lib/rgfa/linear_paths.rb',
              'lib/rgfa/lines.rb',
              'lib/rgfa/links.rb',
              'lib/rgfa/logger.rb',
              'lib/rgfa/multiplication.rb',
              'lib/rgfa/numeric_array.rb',
              'lib/rgfa/paths.rb',
              'lib/rgfa/placeholder.rb',
              'lib/rgfa/rgl.rb',
              'lib/rgfa/segment_ends_path.rb',
              'lib/rgfa/segment_info.rb',
              'lib/rgfa/segments.rb',
              'lib/rgfa/sequence.rb',
              'lib/rgfa/trace.rb',
              'lib/rgfatools.rb',
              'lib/rgfatools/artifacts.rb',
              'lib/rgfatools/copy_number.rb',
              'lib/rgfatools/invertible_segments.rb',
              'lib/rgfatools/multiplication.rb',
              'lib/rgfatools/superfluous_links.rb',
              'lib/rgfatools/linear_paths.rb',
              'lib/rgfatools/p_bubbles.rb',
              'bin/gfadiff',
              'bin/rgfa-mergelinear',
              'bin/rgfa-simdebruijn',
              'bin/rgfa-findcrisprs',
            ]
  s.homepage = 'http://github.com/ggonnella/rgfa'
  s.license = 'CC-BY-SA'
  s.required_ruby_version = '>= 2.0'
end
