import unittest
import gfapy

class TestSequence(unittest.TestCase):
  pass

  #TODO: fix test
  #def test_rc(self):
  #  self.assertEqual("gcatcgatcgt", gfapy.sequence.rc("acgatcgatgc"))
  #  self.assertEqual("gCaTCgatcgt", gfapy.sequence.rc("acgatcGAtGc"))
  #  self.assertEqual("gcatcnatcgt", gfapy.sequence.rc("acgatngatgc"))
  #  self.assertEqual("gcatcYatcgt", gfapy.sequence.rc("acgatRgatgc"))
  #  self.assertRaises(gfapy.InconsistencyError, gfapy.sequence.rc, "acgatUgatgc")
  #  self.assertEqual("gcaucgaucgu", gfapy.sequence.rc("acgaucgaugc"))
  #  self.assertEqual("===.", gfapy.sequence.rc(".==="))
  #  self.assertRaises(gfapy.ValueError, gfapy.sequence.rc, "acgatXgatgc")
  #  self.assertEqual("*", gfapy.sequence.rc("*"))
  #  self.assertRaises(gfapy.ValueError, gfapy.sequence.rc, "**")
