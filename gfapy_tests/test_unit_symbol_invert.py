import unittest
import gfapy

class TestUnitSymbolInvert(unittest.TestCase):

  def test_invert_orientations(self):
    self.assertEqual("+", gfapy.invert("-"))
    self.assertEqual("-", gfapy.invert("+"))

  def test_invert_segment_ends(self):
    self.assertEqual("L", gfapy.invert("R"))
    self.assertEqual("R", gfapy.invert("L"))

  def test_invert_invalid(self):
    self.assertRaises(gfapy.ValueError, gfapy.invert, "xx")

