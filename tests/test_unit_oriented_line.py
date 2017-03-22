import unittest
import gfapy

class TestUnitOrientedLine(unittest.TestCase):

  def test_init(self):
    a = gfapy.OrientedLine("a","+")
    # no validation on creation: (invalid orientation)
    gfapy.OrientedLine("a","*")
    # no validation on creation: (invalid line name)
    gfapy.OrientedLine("a\ta","+")
    b = gfapy.OrientedLine("a+")
    self.assertEqual(a, b)
    c = gfapy.OrientedLine(["a","+"])
    self.assertEqual(a, c)
    self.assertRaises(IndexError, gfapy.OrientedLine, [])
    self.assertRaises(IndexError, gfapy.OrientedLine, ["a"])
    # nothing raised, if too many args are provided (further are ignored)
    gfapy.OrientedLine(["a", "+", 1])

  def test_properties(self):
    a = gfapy.OrientedLine("a", "+")
    self.assertEqual("a", a.line)
    self.assertEqual("+", a.orient)
    self.assertEqual("a", a.name)
    s = gfapy.Line("S\tb\t*\txx:Z:1.0")
    a.line = s
    self.assertEqual(s, a.line)
    self.assertEqual("b", a.name)
    self.assertEqual("+", a.orient)
    a.orient = "-"
    self.assertEqual(s, a.line)
    self.assertEqual("-", a.orient)

  def test_validate(self):
    gfapy.OrientedLine("a","+").validate()
    gfapy.OrientedLine(gfapy.Line("S\tb\t*\txx:Z:1.0"),
                       "-").validate()
    self.assertRaises(gfapy.ValueError,
        gfapy.OrientedLine("a","*").validate)
    self.assertRaises(gfapy.TypeError,
        gfapy.OrientedLine([],"+").validate)
    self.assertRaises(gfapy.FormatError,
        gfapy.OrientedLine("a\ta","+").validate)


  def test_inverted(self):
    os = gfapy.OrientedLine("a", "+")
    inv_os = os.inverted()
    self.assertEqual("a", inv_os.line)
    self.assertEqual("+", os.orient)
    self.assertEqual("-", inv_os.orient)
    s = gfapy.Line("S\tb\t*\txx:Z:1.0")
    os = gfapy.OrientedLine(s, "-")
    inv_os = os.inverted()
    self.assertEqual(s, inv_os.line)
    self.assertEqual("-", os.orient)
    self.assertEqual("+", inv_os.orient)
    os = gfapy.OrientedLine("a", "*")
    self.assertRaises(gfapy.ValueError, os.invert)

  def test_str(self):
    self.assertEqual("a-", str(gfapy.OrientedLine("a","-")))
    s = gfapy.Line("S\tb\t*\txx:Z:1.0")
    self.assertEqual("b+", str(gfapy.OrientedLine(s,"+")))

  def test_equal(self):
    a = gfapy.OrientedLine("a", "+")
    b = gfapy.OrientedLine(gfapy.Line("S\ta\t*"), "+")
    c = gfapy.OrientedLine("a", "-")
    self.assertEqual(a, b)
    self.assertNotEqual(a, c)
    # line itself is not checked for equiv, only name:
    b2 = gfapy.OrientedLine(gfapy.Line("S\ta\tCACAC"), "+")
    self.assertEqual(b, b2)
    # equivalence to string:
    self.assertEqual("a+", a)
    self.assertEqual("a+", b)
    self.assertEqual(a, "a+")
    self.assertEqual(b, "a+")
    # equivalence to list:
    self.assertEqual(a, ["a", "+"])
    self.assertEqual(b, ["a", "+"])
    self.assertEqual(["a", "+"], a)
    self.assertEqual(["a", "+"], b)

  def test_block(self):
    a = gfapy.OrientedLine("a", "+")
    a._block()
    with self.assertRaises(gfapy.RuntimeError):
      a.line = "b"
    a._unblock()
    a.line = "b"

  def test_delegate_methods(self):
    ol = gfapy.OrientedLine(gfapy.Line("S\ta\tCACAC"), "+")
    self.assertEqual("CACAC", ol.sequence)
    self.assertEqual("CACAC", ol.field_to_s("sequence"))
    ol.set("xx", 1)
    self.assertEqual("xx:i:1", ol.field_to_s("xx", True))
