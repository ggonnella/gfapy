import unittest
import gfapy

class TestAlignment(unittest.TestCase):
  
  def test_from_string_cigar(self):
    self.assertEqual(gfapy.CIGAR([
      gfapy.CIGAR.Operation(12, "M"),
      gfapy.CIGAR.Operation(1,  "D"),
      gfapy.CIGAR.Operation(2,  "I"),
      ]), gfapy.Alignment.from_string("12M1D2I"))

  def test_from_string_placeholder(self):
    self.assertIsInstance(gfapy.Alignment.from_string("*"), gfapy.Placeholder)

  def test_from_string_trace(self):
    self.assertEqual(gfapy.Trace([12,14,15]), 
                     gfapy.Alignment.from_string("12,14,15"))

  def test_from_string_invalid(self):
    self.assertRaises(gfapy.FormatError, 
                      gfapy.Alignment.from_string, ("12x1,D2I"))
    
  def test_from_array_cigar(self):
    self.assertEqual(gfapy.CIGAR([
      gfapy.CIGAR.Operation(12, "M"),
      gfapy.CIGAR.Operation(1,  "D"),
      gfapy.CIGAR.Operation(2, "I")]),
      gfapy.Alignment.from_list(
      [gfapy.CIGAR.Operation(12, "M"),
       gfapy.CIGAR.Operation(1,  "D"),
       gfapy.CIGAR.Operation(2,  "I")]))

  def test_from_array_trace(self):
    self.assertEqual(gfapy.Trace([12,14,15]), 
                     gfapy.Alignment.from_list([12,14,15]))

  def test_from_array_invalid(self):
    self.assertRaises(gfapy.FormatError,
                      gfapy.Alignment.from_list, ["12x1", "2I"])
