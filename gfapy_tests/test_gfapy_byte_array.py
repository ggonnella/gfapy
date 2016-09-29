import unittest
import gfapy

class TestByteArray(unittest.TestCase):

  def test_byte_array_creation(self):
    a = gfapy.ByteArray([1,2,3,4,5])
    for i in range(1,5):
      self.assertEqual(a[i-1], i)

  def test_byte_array_validation(self):
    a = gfapy.ByteArray([1,2,3,4,5]) 
    self.assertRaises(gfapy.ValueError, gfapy.ByteArray, [1,2,3,4,356])

  def test_from_string(self):
    a = gfapy.ByteArray("12ACF4AA601C1F")
    b = gfapy.ByteArray([18, 172, 244, 170, 96, 28, 31])
    self.assertEqual(a,b)
    self.assertRaises(gfapy.FormatError, gfapy.ByteArray, "12ACF4AA601C1")

  def test_to_string(self):
    a = gfapy.ByteArray([18,172,244,170,96,28,31])
    b = "12ACF4AA601C1F"
    c = gfapy.ByteArray(b)
    self.assertEqual(str(a), b)
    #self.assertEqual(str(c), b)

