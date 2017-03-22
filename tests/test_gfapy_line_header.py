import unittest
import gfapy

class TestLineHeader(unittest.TestCase):

  def test_from_string(self):
    gfapy.Line("H\tVN:Z:1.0")
    self.assertIsInstance(gfapy.Line("H\tVN:Z:1.0"), gfapy.line.Header)
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line("H\tH2\tVN:Z:1.0")
    with self.assertRaises(gfapy.TypeError):
      gfapy.Line("H\tVN:i:1.0")
