import unittest
import gfapy

class TestCigar(unittest.TestCase):

  def test_from_string_nonempty(self):
    self.assertEqual(gfapy.CIGAR([gfapy.CIGAR.Operation(12, "M"),
                                  gfapy.CIGAR.Operation( 1, "D"),
                                  gfapy.CIGAR.Operation( 2, "I")]),
                     gfapy.CIGAR._from_string("12M1D2I"))

  def test_from_string_empty(self):
    self.assertEqual(gfapy.Placeholder, gfapy.CIGAR._from_string("*"))

  def test_from_string_invalid(self):
    with self.assertRaises(gfapy.FormatError):
      gfapy.CIGAR._from_string("12x1D2I")

  def test__str__noempty(self):
    self.assertEqual("12M1D2I",
                     str(gfapy.CIGAR([gfapy.CIGAR.Operation(12, "M"),
                                      gfapy.CIGAR.Operation( 1, "D"),
                                      gfapy.CIGAR.Operation( 2, "I")])))
