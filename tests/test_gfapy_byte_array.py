import unittest
import gfapy

class TestByteArray(unittest.TestCase):

  def test_byte_arrays(self):
    # creation: from list, from string
    a_lst = [18, 172, 244, 170, 96, 28, 31]
    a = gfapy.ByteArray(a_lst)
    for i in range(0,len(a_lst)):
      self.assertEqual(a[i], a_lst[i])
    a_str = "12ACF4AA601C1F"
    b = gfapy.ByteArray(a_str)
    self.assertEqual(a,b)
    # validation
    self.assertRaises(gfapy.ValueError, gfapy.ByteArray, [1,2,3,4,356])
    self.assertRaises(gfapy.FormatError, gfapy.ByteArray, "12ACF4AA601C1")
    self.assertRaises(gfapy.FormatError, gfapy.ByteArray, "")
    self.assertRaises(gfapy.FormatError, gfapy.ByteArray, "12ACG4AA601C1")
    # to_s
    self.assertEqual(str(b), a_str)
    self.assertEqual(str(a), a_str)
    # read only; transform to list to edit a value
    tmp = list(a)
    tmp[3]=1
    a = gfapy.ByteArray(tmp)
    self.assertEqual(a, gfapy.ByteArray([18,172,244,1,96,28,31]))

