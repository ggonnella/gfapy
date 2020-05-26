import unittest
import gfapy

class TestUnitLine(unittest.TestCase):

  def test_initialize_not_enough_positional_fields(self):
    gfapy.Line(["S", "1", "*"])
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line(["S", "1"])

  def test_initialize_too_many_positionals(self):
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line(["S", "1", "*", "*"])

  def test_initialize_predefined_tag_wrong_type(self):
    gfapy.line.Header(["H", "VN:Z:1"])
    with self.assertRaises(gfapy.TypeError):
      gfapy.line.Header(["H", "VN:i:1"])

  def test_initialize_wrong_tag_format(self):
    with self.assertRaises(gfapy.FormatError):
      gfapy.line.Header(["H", "VN i:1"])

  def test_initialize_positional_field_type_error(self):
    with self.assertRaises(gfapy.FormatError):
      gfapy.line.segment.GFA1(["S", "1\t1", "*", "*"])

  def test_initialize_tag_type_error(self):
    with self.assertRaises(gfapy.FormatError):
      gfapy.line.Header(["H", "zz:i:1A"])

  def test_initialize_duplicate_tag(self):
    with self.assertRaises(gfapy.NotUniqueError):
      gfapy.line.Header(["H", "zz:i:1", "zz:i:2"])
    with self.assertRaises(gfapy.NotUniqueError):
      gfapy.line.Header(["H", "zz:i:1", "VN:Z:1", "zz:i:2"])

  def test_initialize_custom_tag(self):
    gfapy.line.Header(["H", "ZZ:Z:1"]) # nothing raised

  def test_record_type(self):
    l = gfapy.line.Header(["H", "xx:i:13", "VN:Z:HI"])
    self.assertEqual("H", l.record_type)
    with self.assertRaises(AttributeError):
      l.record_type = "S"

  def test_add_tag(self):
    l = gfapy.line.Header(["H", "xx:i:13", "VN:Z:HI"])
    self.assertEqual(None, l.xy)
    l.set("xy", "HI")
    self.assertEqual("HI", l.xy)

  def test_unknown_record_type(self):
    with self.assertRaises(gfapy.VersionError):
      gfapy.Line("Z\txxx", version = "gfa1")
    gfapy.Line("Z\txxx", version = "gfa2")
    gfapy.Line("Z\txxx")

  def test_field_alias(self):
    s = gfapy.Line("S\tA\t*")
    self.assertEqual(s.name, s.get("name"))
    self.assertEqual("A", s.name)
    self.assertEqual("A", s.sid)
    self.assertEqual("A", s.get("name"))
    self.assertEqual("A", s.get("sid"))
    s.set("name", "B")
    self.assertEqual("B", s.get("sid"))
    s.set("sid", "C")
    self.assertEqual("C", s.name)

  def test_to_s(self):
    fields = ["H", "VN:Z:HI", "xx:i:13"]
    l = gfapy.line.Header(fields[:])
    lstr = str(l)
    self.assertEqual("\t".join(fields), lstr)

  def test_clone(self):
    l = gfapy.Line("H\tVN:Z:1.0")
    l1 = l
    l2 = l.clone()
    self.assertIsInstance(l, gfapy.line.Header)
    self.assertIsInstance(l2, gfapy.line.Header)
    l2.VN = "2.0"
    self.assertEqual("2.0", l2.VN)
    self.assertEqual("1.0", l.VN)
    l1.VN = "2.0"
    self.assertEqual("2.0", l.VN)

