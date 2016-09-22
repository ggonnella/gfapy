The Graphical Fragment Assembly (GFA) is a proposed format which allow
to describe the product of sequence assembly.
This gem implements the proposed specifications for the GFA format
described under https://github.com/GFA-spec/GFA-spec/blob/master/GFA-spec.md
as close as possible.

The library allows to create a RGFA object from a file in the GFA format
or from scratch, to enumerate the graph elements (segments, links,
containments, paths and header lines), to traverse the graph (by
traversing all links outgoing from or incoming to a segment), to search for
elements (e.g. which links connect two segments) and to manipulate the
graph (e.g. to eliminate a link or a segment or to duplicate a segment
distributing the read counts evenly on the copies).

## Installation

The latest release of the gem can be installed from the rubygems repository
using:
```gem install rgfa```

Alternatively this git repository can be cloned or the source code
installed from a release archive, and then the gem created and installed
using:
```rake install```

## Usage

To use the library in your Ruby scripts, just require it as follows:
```require "rgfa"```

Additional functionality, which
requires custom tags and additional conventions, is included in a separate
part of the code named {RGFATools} and can be accessed with:
```require "rgfatools"```

## Documentation

A cheatsheet is available as pdf under
https://github.com/ggonnella/rgfa/blob/master/cheatsheet/rgfa-cheatsheet-1.2.pdf

The full API documentation is available as pdf under
https://github.com/ggonnella/rgfa/blob/master/pdfdoc/rgfa-api-1.2.pdf
or in HTML format (http://www.rubydoc.info/github/ggonnella/rgfa/master/RGFA).

The main class of the library is {RGFA}, which is a good starting point
when reading the documentation.

## References

The manuscript describing the library has been presented at the
German Conference on Bioinformatics 2016. Currently it is under review and
available as a Peer Journal preprint:

Gonnella G, Kurtz S. (2016) RGFA: powerful and convenient handling of
assembly graphs. PeerJ Preprints 4:e2381v1
https://doi.org/10.7287/peerj.preprints.2381v1

