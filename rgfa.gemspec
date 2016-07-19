Gem::Specification.new do |s|
  s.name = 'rgfa'
  s.version = '1.1'
  s.date = '2016-07-13'
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
              'lib/rgfa/connection_info.rb',
              'lib/rgfa/error.rb',
              'lib/rgfa/field_writer.rb',
              'lib/rgfa/field_parser.rb',
              'lib/rgfa/field_validator.rb',
              'lib/rgfa/edit.rb',
              'lib/rgfa/line_creators.rb',
              'lib/rgfa/line_destructors.rb',
              'lib/rgfa/line_getters.rb',
              'lib/rgfa/line.rb',
              'lib/rgfa/logger.rb',
              'lib/rgfa/numeric_array.rb',
              'lib/rgfa/rgl.rb',
              'lib/rgfa/segment_info.rb',
              'lib/rgfa/segment_references.rb',
              'lib/rgfa/sequence.rb',
              'lib/rgfa/traverse.rb',
              'lib/rgfa/line/containment.rb',
              'lib/rgfa/line/header.rb',
              'lib/rgfa/line/link.rb',
              'lib/rgfa/line/path.rb',
              'lib/rgfa/line/segment.rb',
            ]
  s.homepage = 'http://github.com/ggonnella/ruby-gfa'
  s.license = 'CC-BY-SA'
  s.required_ruby_version = '>= 2.0'
end
