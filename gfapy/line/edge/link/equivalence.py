import gfapy

class Equivalence:

  def __hash__(self):
    """
    Computes an hash for including the link in a dict,
    so that the hash of a link and its complement is the same.
    Thereby, tags are not considered.
    """
    hash(str(self.from_end)) + \
    hash(str(self.to_end)) + \
    hash(str(self.overlap)) + \
    hash(str(self.overlap.complement()))

  def is_eql(self, other):
    """
    Compares two links and determine their equivalence.
    Thereby, tags are not considered.

    .. note::
      Inverting the strand of both links and reversing
      the CIGAR operations (order/type), one obtains an
      equivalent complement link.

    Parameters
    ----------
    other : gfapy.line.edge.Link
      A link.

    Returns
    -------
    bool
      Are self and other equivalent?

    See Also
    --------
    ==
    is_same
    is_complement
    """
    return (self.is_same(other) or self.is_complement(other))

  def are_tags_eql(self, other):
    """
    Compares the tags of two links.

    .. note::
      This method shall be overridden if custom tags
      are defined, which have a complementation operation which determines
      their value in the equivalent but complement link.

    Parameters
    ----------
    other : gfapy.line.edge.Link
      A link.

    Returns
    -------
    bool
      Are self and other equivalent?

    See Also
    --------
    __eq__
    """
    return (sorted(self.tagnames) == sorted(other.tagnames)) and \
            all(self.get(fn) == other.get(fn) for fn in self.tagnames)

#  def __eq__(self, other):
#    """
#    Compares two links and determine their equivalence.
#    Tags must have the same content.
#
#    .. note:: Inverting the strand of both links and reversing
#    the CIGAR operations (order/type), one obtains an equivalent
#    link.
#
#    Parameters
#    ----------
#    other : gfapy.line.edge.Link
#      A link.
#
#    Returns
#    -------
#    bool
#      Are self and other equivalent?
#
#    See Also
#    --------
#    is_eql
#    are_tags_eql
#    """
#    return self.is_eql(other) and self.are_tags_eql(other)

  def is_same(self, other):
    """
    Compares two links and determine their equivalence.
    Thereby, tags are not considered.

    Parameters
    ----------
    other : gfapy.line.edge.Link
      A link.

    Returns
    -------
    bool
      Are self and other equivalent?

    See Also
    --------
    is_eql
    is_complement
    __eq__
    """
    return (self.from_end == other.from_end and
            self.to_end == other.to_end and
            self.overlap == other.overlap)

  def is_complement(self, other):
    """
    Compares the link to the complement of another link
    and determine their equivalence.
    Thereby, tags are not considered.

    Parameters
    ----------
    other : gfapy.line.edge.Link
      The other link.

    Returns
    -------
    bool
      Are self and the complement of other equivalent?

    See Also
    --------
    is_eql
    is_same
    __eq__
    """
    return (self.from_end == other.to_end and
            self.to_end == other.from_end and
            self.overlap == other.overlap.complement())

  def is_compatible(self, other_oriented_from, other_oriented_to,
                    other_overlap = None, allow_complement = True):
    """
    Compares a link and optionally the complement link,
    with two oriented_segments and optionally an overlap.

    Parameters
    ----------
    other_oriented_from : gfapy.OrientedLine
    other_oriented_to : gfapy.OrientedLine
    allow_complement : bool
      Shall the complement link also be considered?
    other_overlap : gfapy.Alignment.CIGAR
      Compared only if not empty.

    Returns
    -------
    bool
      Does the link or, if **allow_complement**, the complement link go from
      the first, oriented segment to the second with an overlap equal to the
      provided one (if not empty)?
    """
    other_overlap = gfapy.Alignment(other_overlap, version = "gfa1",
        valid = True)
    if self.is_compatible_direct(other_oriented_from, other_oriented_to,
        other_overlap):
      return True
    elif allow_complement:
      return self.is_compatible_complement(other_oriented_from,
                                           other_oriented_to,
                                           other_overlap)
    else:
      return False

  def is_compatible_direct(self, other_oriented_from, other_oriented_to,
                           other_overlap = None):
    """
    Compares a link with two oriented segments and optionally an overlap.

    Parameters
    ----------
    other_oriented_from : gfapy.OrientedLine
    other_oriented_to : gfapy.OrientedLine
    other_overlap : gfapy.Alignment.CIGAR
      Compared only if not empty.

    Returns
    -------
    bool
      Does the link go from the first oriented segment to the second
      with an overlap equal to the provided one (if not empty)?
    """
    return ((self.oriented_from == other_oriented_from and
             self.oriented_to == other_oriented_to) and
           (not self.overlap or not other_overlap or
             (self.overlap == other_overlap)))

  def is_compatible_complement(self, other_oriented_from, other_oriented_to,
                               other_overlap = None):
    """
    Compares the complement link with two oriented segments and optionally an
    overlap.

    Parameters
    ----------
    other_oriented_from : gfapy.OrientedLine
    other_oriented_to : gfapy.OrientedLine
    other_overlap : gfapy.Alignment.CIGAR
      Compared only if not empty.

    Returns
    -------
    bool
      Does the complement link go from the first oriented segment
      to the second with an overlap equal to the provided one (if not empty)?
    """
    return ((self.oriented_to == other_oriented_from.inverted() and
            (self.oriented_from == other_oriented_to.inverted()) and
            (not self.overlap or not other_overlap or
            (self.overlap == other_overlap.complement()))))

  def _complement_ends(self, other):
    return (self.from_end == other.to_end and self.to_end == other.from_end)
