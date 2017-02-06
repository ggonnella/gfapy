import unittest
import gfapy

class TestNumericArray(unittest.TestCase):

  def test_numeric_arrays(self):
    # creation: new, from array, from string
    a = gfapy.NumericArray([1,2,3,4,5])
    b = gfapy.NumericArray.from_string("i,1,2,3,4,5")
    self.assertEqual(a, b)
    # validation
    a.validate
    gfapy.NumericArray([1,2,3,4,356]).validate
    self.assertRaises(gfapy.ValueError,
        gfapy.NumericArray([1,2.0,3,4,356]).validate)
    self.assertRaises(gfapy.ValueError,
        gfapy.NumericArray([1.0,2.0,3.0,4.0,356]).validate)
    self.assertRaises(gfapy.ValueError,
        gfapy.NumericArray([1,"x",3,4,356]).validate)
    self.assertRaises(gfapy.ValueError,
        gfapy.NumericArray.from_string, "i,1,X,2")
    self.assertRaises(gfapy.FormatError,
        gfapy.NumericArray.from_string, "")
    self.assertRaises(gfapy.FormatError,
        gfapy.NumericArray.from_string, "i,1,2,")
    self.assertRaises(gfapy.TypeError,
        gfapy.NumericArray.from_string, "x,1,2")
    # to string
    a = gfapy.NumericArray([18, 72, 244, 70, 96, 38, 31])
    self.assertEqual("C", a.compute_subtype())
    self.assertEqual("C,18,72,244,70,96,38,31", str(a))
    a[2] = -2
    self.assertEqual("c", a.compute_subtype())
    self.assertEqual("c,18,72,-2,70,96,38,31", str(a))
    a[2] = 280
    self.assertEqual("S", a.compute_subtype())
    self.assertEqual("S,18,72,280,70,96,38,31", str(a))
    a[2] = -280
    self.assertEqual("s", a.compute_subtype())
    self.assertEqual("s,18,72,-280,70,96,38,31", str(a))
    a[2] = 280000
    self.assertEqual("I", a.compute_subtype())
    self.assertEqual("I,18,72,280000,70,96,38,31", str(a))
    a[2] = -280000
    self.assertEqual("i", a.compute_subtype())
    self.assertEqual("i,18,72,-280000,70,96,38,31", str(a))
    a = gfapy.NumericArray([18.0, 72.0, -280000.0, 70.0, 96.0, 38.0, 31.0])
    self.assertEqual("f", a.compute_subtype())
    self.assertEqual("f,18.0,72.0,-280000.0,70.0,96.0,38.0,31.0", str(a))
