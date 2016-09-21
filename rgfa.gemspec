Gem::Specification.new do |s|
  s.name = 'rgfa'
  s.version = '1.2.1'
  s.date = '2016-09-21'
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
              'lib/rgfa/byte_array.rb',
              'lib/rgfa/cigar.rb',
              'lib/rgfa/connectivity.rb',
              'lib/rgfa/containments.rb',
              'lib/rgfa/error.rb',
              'lib/rgfa/field_array.rb',
              'lib/rgfa/field_writer.rb',
              'lib/rgfa/field_parser.rb',
              'lib/rgfa/field_validator.rb',
              'lib/rgfa/headers.rb',
              'lib/rgfa/line/containment.rb',
              'lib/rgfa/line/header.rb',
              'lib/rgfa/line/link.rb',
              'lib/rgfa/line/path.rb',
              'lib/rgfa/line/segment.rb',
              'lib/rgfa/line.rb',
              'lib/rgfa/linear_paths.rb',
              'lib/rgfa/lines.rb',
              'lib/rgfa/links.rb',
              'lib/rgfa/logger.rb',
              'lib/rgfa/multiplication.rb',
              'lib/rgfa/numeric_array.rb',
              'lib/rgfa/paths.rb',
              'lib/rgfa/rgl.rb',
              'lib/rgfa/segment_ends_path.rb',
              'lib/rgfa/segment_info.rb',
              'lib/rgfa/segments.rb',
              'lib/rgfa/sequence.rb',
              'lib/rgfatools.rb',
              'lib/rgfatools/artifacts.rb',
              'lib/rgfatools/copy_number.rb',
              'lib/rgfatools/invertible_segments.rb',
              'lib/rgfatools/multiplication.rb',
              'lib/rgfatools/superfluous_links.rb',
              'lib/rgfatools/linear_paths.rb',
              'lib/rgfatools/p_bubbles.rb',
              'bin/gfadiff.rb',
              'bin/rgfa-mergelinear.rb',
              'bin/rgfa-simdebruijn.rb',
              'bin/rgfa-findcrisprs.rb',
            ]
  s.homepage = 'http://github.com/ggonnella/rgfa'
  s.license = 'CC-BY-SA'
  s.required_ruby_version = '>= 2.0'
end
