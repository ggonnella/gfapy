The Graphical Fragment Assembly (GFA) is a proposed format which allow
to describe the product of sequence assembly.
This gem implements the proposed specifications for the GFA format
described under https://github.com/pmelsted/GFA-spec/blob/master/GFA-spec.md
as close as possible.

The library allows to create a GFA object from a file in the GFA format
or from scratch, to enumerate the graph elements (segments, links,
containments, paths and header lines), to traverse the graph (by
traversing all links outgoing from or incoming to a segment), to search for
elements (e.g. which links connect two segments) and to manipulate the
graph (e.g. to eliminate a link or a segment or to duplicate a segment
distributing the read counts evenly on the copies).
