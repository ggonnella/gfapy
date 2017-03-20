import unittest
import gfapy

class TestAlignment(unittest.TestCase):

  def test_string_to_cigar(self):
    self.assertEqual(gfapy.CIGAR([
      gfapy.CIGAR.Operation(12, "M"),
      gfapy.CIGAR.Operation(1,  "D"),
      gfapy.CIGAR.Operation(2,  "I"),
      ]), gfapy.Alignment("12M1D2I"))

  def test_string_to_placeholder(self):
    self.assertIsInstance(gfapy.Alignment("*"), gfapy.Placeholder)

  def test_string_to_trace(self):
    self.assertEqual(gfapy.Trace([12,14,15]),
                     gfapy.Alignment("12,14,15"))

  def test_string_invalid(self):
    self.assertRaises(gfapy.FormatError,
                      gfapy.Alignment, "12x1,D2I")

  def test_list_to_cigar(self):
    self.assertEqual(gfapy.CIGAR([
      gfapy.CIGAR.Operation(12, "M"),
      gfapy.CIGAR.Operation(1,  "D"),
      gfapy.CIGAR.Operation(2, "I")]),
      gfapy.Alignment(
      [gfapy.CIGAR.Operation(12, "M"),
       gfapy.CIGAR.Operation(1,  "D"),
       gfapy.CIGAR.Operation(2,  "I")]))

  def test_list_to_trace(self):
    self.assertEqual(gfapy.Trace([12,14,15]),
                     gfapy.Alignment([12,14,15]))

  def test_list_invalid(self):
    self.assertRaises(gfapy.FormatError,
                      gfapy.Alignment,["12x1", "2I"])
