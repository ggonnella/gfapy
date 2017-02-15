import gfapy
import unittest

class TestAPIPositions(unittest.TestCase):

  def test_positions(self):
    # from string and integer
    pos1 = gfapy.LastPos(12); pos2 = gfapy.LastPos("12$")
    self.assertEqual(pos1, pos2)
    assert(isinstance(pos1, gfapy.LastPos))
    assert(isinstance(pos2, gfapy.LastPos))
    # value
    self.assertEqual(12, gfapy.posvalue(pos1))
    self.assertEqual(12, gfapy.posvalue(pos2))
    self.assertEqual(12, gfapy.posvalue(12))
    # to_pos on string without dollar
    self.assertEqual(12, gfapy.LastPos("12"))
    assert(isinstance(gfapy.LastPos("12"), int))
    # to pos: wrong format
    with self.assertRaises(gfapy.FormatError): gfapy.LastPos("12=")
    # 0$ is allowed, although unclear if useful
    assert(gfapy.islastpos(gfapy.LastPos("0$")))
    # comparison with integer and string
    self.assertEqual(gfapy.LastPos(10), 10)
    self.assertEqual(10, gfapy.LastPos(10))
    # to_s
    self.assertEqual("12$", str(pos1))
    # to_i
    self.assertEqual(12, int(pos1))

  def test_positions_negative(self):
    # negative values
    with self.assertRaises (gfapy.ValueError): gfapy.LastPos("-1")
    with self.assertRaises (gfapy.ValueError): gfapy.LastPos("-1$")
    # negative values, valid: True
    self.assertEqual(-1, gfapy.LastPos("-1",valid=True))
    assert(isinstance(gfapy.LastPos("-1",valid=True), int))
    self.assertEqual(gfapy.LastPos(-1, valid=True), gfapy.LastPos("-1$",valid=True))
    self.assertEqual(gfapy.LastPos(-1, valid=True), gfapy.LastPos(-1,valid=True))
    # validate
    with self.assertRaises (gfapy.ValueError): gfapy.LastPos("-1$",valid=True).validate()
    with self.assertRaises (gfapy.ValueError): gfapy.LastPos(-1,valid=True).validate()

  def test_positions_first_last(self):
    assert(not gfapy.islastpos(gfapy.LastPos("0")))
    assert(not gfapy.islastpos(gfapy.LastPos("12")))
    assert(gfapy.islastpos(gfapy.LastPos("12$")))
    assert(gfapy.isfirstpos(gfapy.LastPos("0")))
    assert(not gfapy.isfirstpos(gfapy.LastPos("12")))
    assert(not gfapy.isfirstpos(gfapy.LastPos("12$")))

  def test_positions_subtract(self):
    a = gfapy.LastPos("13$")
    a1 = a - 0
    a2 = a - 1
    self.assertEqual(13, a1)
    self.assertEqual(12, a2)
    assert(gfapy.islastpos(a1))
    assert(not gfapy.islastpos(a2))

