import unittest
import gfapy

class TestUnitNumericArray(unittest.TestCase):

  def test_integer_type(self):
    v = {b: 2**(b/2) for b in [8,16,32,64,128]}
    self.assertEqual("C", gfapy.NumericArray.integer_type((0,v[8])))
    self.assertEqual("c", gfapy.NumericArray.integer_type((-1,v[8])))
    self.assertEqual("S", gfapy.NumericArray.integer_type((0,v[16])))
    self.assertEqual("s", gfapy.NumericArray.integer_type((-1,v[16])))
    self.assertEqual("I", gfapy.NumericArray.integer_type((0,v[32])))
    self.assertEqual("i", gfapy.NumericArray.integer_type((-1,v[32])))
    self.assertRaises(gfapy.ValueError,
        gfapy.NumericArray.integer_type, (0,v[64]))
    self.assertRaises(gfapy.ValueError,
        gfapy.NumericArray.integer_type, (-1,v[64]))
    self.assertRaises(gfapy.ValueError,
        gfapy.NumericArray.integer_type, (0,v[128]))
    self.assertRaises(gfapy.ValueError,
        gfapy.NumericArray.integer_type, (-1,v[128]))
