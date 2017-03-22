import gfapy
import unittest

class TestSegmentReferences(unittest.TestCase):

  def test_link_other(self):
    l = gfapy.Line("L\t1\t+\t2\t-\t*")
    self.assertEqual("2", l.other("1"))
    self.assertEqual("1", l.other("2"))
    self.assertRaises(gfapy.NotFoundError, l.other, "0")

  def test_link_circular(self):
    l = gfapy.Line("L\t1\t+\t2\t-\t*")
    self.assertEqual(False, l.is_circular())
    l = gfapy.Line("L\t1\t+\t1\t-\t*")
    self.assertEqual(True, l.is_circular())
