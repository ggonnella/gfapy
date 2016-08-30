The Graphical Fragment Assembly (GFA) is a proposed format which allow
to describe the product of sequence assembly.
This gem implements the proposed specifications for the GFA format
described under https://github.com/pmelsted/GFA-spec/blob/master/GFA-spec.md
as close as possible.

The library allows to create a RGFA object from a file in the GFA format
or from scratch, to enumerate the graph elements (segments, links,
containments, paths and header lines), to traverse the graph (by
traversing all links outgoing from or incoming to a segment), to search for
elements (e.g. which links connect two segments) and to manipulate the
graph (e.g. to eliminate a link or a segment or to duplicate a segment
distributing the read counts evenly on the copies).

The API documentation is available as pdf under
https://github.com/ggonnella/rgfa/blob/master/pdfdoc/rgfa-api-1.1.pdf
or in HTML format (http://www.rubydoc.info/github/ggonnella/rgfa/master/RGFA).

The RGFATools gem is available at
https://github.com/ggonnella/rgfatools/.

## References

The manuscript describing the library has been accepted for presentation at the German Conference on Bioinformatics 2016. Currently it is available as Peer Journal preprint (as soon as it is peer reviewed, the reference will be updated):

Gonnella G, Kurtz S. (2016) RGFA: powerful and convenient handling of assembly graphs. PeerJ Preprints 4:e2381v1 https://doi.org/10.7287/peerj.preprints.2381v1

