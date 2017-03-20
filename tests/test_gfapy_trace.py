import unittest
import gfapy

class TestTrace(unittest.TestCase):
  def test_from_string(self):
    self.assertEqual(gfapy.Trace([12,14,15]), gfapy.Trace._from_string("12,14,15"))
    with self.assertRaises(gfapy.FormatError):
      gfapy.Trace._from_string("12x,12,12")

  def test_validation(self):
    gfapy.Trace._from_string("12,12,12").validate()
    self.assertRaises(gfapy.ValueError, gfapy.Trace._from_string("12,12,12").validate, ts = 10)
    self.assertRaises(gfapy.ValueError, gfapy.Trace._from_string("12,-12,12").validate, ())
    self.assertRaises(gfapy.TypeError, gfapy.Trace(["12x",12,12]).validate, ())

  def test_str(self):
    self.assertEqual("12,12,12", str(gfapy.Trace([12,12,12])))
