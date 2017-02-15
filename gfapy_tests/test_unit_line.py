import unittest
import gfapy

class TestUnitLine(unittest.TestCase):

  def test_initialize_not_enough_positional_fields(self):
    gfapy.line.segment.Factory(["1", "*"])
    with self.assertRaises(gfapy.FormatError):
      gfapy.line.segment.Factory(["1"])

  def test_initialize_too_many_positionals(self):
    with self.assertRaises(gfapy.FormatError):
      gfapy.line.segment.Factory(["1", "*", "*"])

  def test_initialize_predefined_tag_wrong_type(self):
    gfapy.line.Header(["VN:Z:1"])
    with self.assertRaises(gfapy.TypeError):
      gfapy.line.Header(["VN:i:1"])

  def test_initialize_wrong_tag_format(self):
    with self.assertRaises(gfapy.FormatError):
      gfapy.line.Header(["VN i:1"])

  def test_initialize_positional_field_type_error(self):
    with self.assertRaises(gfapy.FormatError):
      gfapy.line.segment.Factory(["1\t1", "*", "*"])

  def test_initialize_tag_type_error(self):
    with self.assertRaises(gfapy.FormatError):
      gfapy.line.Header(["zz:i:1A"])

  def test_initialize_duplicate_tag(self):
    with self.assertRaises(gfapy.NotUniqueError):
      gfapy.line.Header(["zz:i:1", "zz:i:2"])
    with self.assertRaises(gfapy.NotUniqueError):
      gfapy.line.Header(["zz:i:1", "VN:Z:1", "zz:i:2"])

  def test_initialize_custom_tag(self):
    with self.assertRaises(gfapy.FormatError):
      gfapy.line.Header(["ZZ:Z:1"])

  def test_record_type(self):
    l = gfapy.line.Header(["xx:i:13", "VN:Z:HI"])
    self.assertEqual("H", l.record_type)
    with self.assertRaises(AttributeError):
      l.record_type = "S"

  def test_add_tag(self):
    l = gfapy.line.Header(["xx:i:13", "VN:Z:HI"])
    self.assertEqual(None, l.xy)
    l.set("xy", "HI")
    self.assertEqual("HI", l.xy)

  def test_unknown_record_type(self):
    with self.assertRaises(gfapy.VersionError):
      gfapy.Line.from_string("Z\txxx", version = "gfa1")
    gfapy.Line.from_string("Z\txxx", version = "gfa2")
    gfapy.Line.from_string("Z\txxx")

  def test_to_gfa_line(self):
    string = "H\tVN:Z:1.0"
    l = gfapy.Line.from_string(string)
    self.assertIsInstance(l, gfapy.line.Header)
    self.assertIsInstance(l.to_gfa_line(), gfapy.line.Header)
    self.assertEqual(string, str(l.to_gfa_line()))
    self.assertEqual(l, l.to_gfa_line())

  def test_field_alias(self):
    s = gfapy.Line.from_string("S\tA\t*")
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
    fields = ["xx:i:13", "VN:Z:HI"]
    l = gfapy.line.Header(fields[:])
    lstr = str(l)
    try:
      self.assertEqual("\t".join(["H"]+fields), lstr)
    except:
      fields.reverse()
      self.assertEqual("\t".join(["H"]+fields), lstr)

  def test_clone(self):
    l = gfapy.Line.from_string("H\tVN:Z:1.0")
    l1 = l
    l2 = l.clone()
    self.assertIsInstance(l, gfapy.line.Header)
    self.assertIsInstance(l2, gfapy.line.Header)
    l2.VN = "2.0"
    self.assertEqual("2.0", l2.VN)
    self.assertEqual("1.0", l.VN)
    l1.VN = "2.0"
    self.assertEqual("2.0", l.VN)

