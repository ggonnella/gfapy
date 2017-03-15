import unittest
import gfapy

class TestLineHeader(unittest.TestCase):

  def test_from_string(self):
    gfapy.Line.from_string("H\tVN:Z:1.0")
    self.assertIsInstance(gfapy.Line.from_string("H\tVN:Z:1.0"), gfapy.line.Header)
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line.from_string("H\tH2\tVN:Z:1.0")
    with self.assertRaises(gfapy.TypeError):
      gfapy.Line.from_string("H\tVN:i:1.0")
