import unittest
import gfapy

class TestLine(unittest.TestCase):

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

  def test_respond_to(self):
    l = gfapy.line.edge.Link(["1", "+", "2", "-", "*", "zz:Z:yes", "KC:i:100"])
    # record_type
    self.assertTrue(hasattr(l, "record_type"))
    # reqfields
    self.assertTrue(hasattr(l, "from"))
    self.assertIsInstance(object.__getattribute__(l, "from"), 
                          gfapy.line.common.dynamic_fields.DynamicField)
    # predefined tags
    self.assertTrue(hasattr(l, "KC"))
    self.assertTrue(hasattr(l, "try_get_KC"))
    self.assertIsInstance(object.__getattribute__(l, "KC"), 
                          gfapy.line.common.dynamic_fields.DynamicField)
    # custom tags
    self.assertTrue(hasattr(l, "zz"))
    self.assertTrue(hasattr(l, "try_get_zz"))
    # not-yet-existing tags
    self.assertTrue(hasattr(l, "aa"))
    #raises exception in python, because hasattr calls getattr
    #self.assertTrue(hasattr(l, "try_get_aa"))

  def test_record_type(self):
    l = gfapy.line.Header(["xx:i:13", "VN:Z:HI"])
    self.assertEqual("H", l.record_type)
    with self.assertRaises(AttributeError):
      l.record_type = "S"

  def test_field_getters_positional_fields(self):
    l = gfapy.line.segment.Factory(["12", "*", "xx:i:13", "KC:i:10"])
    self.assertEqual("12", l.name)
    with self.assertRaises(AttributeError):
      l.zzz

  def test_field_getters_existing_tags(self):
    l = gfapy.line.segment.Factory(["12", "*", "xx:i:13", "KC:i:10"])
    self.assertEqual("xx", l.tagnames[0])
    self.assertEqual("13", l.field_to_s("xx"))
    self.assertEqual(13, l.xx)
    self.assertEqual(13, l.try_get_xx())
    self.assertEqual("10", l.field_to_s("KC"))
    self.assertEqual(10, l.KC)
    self.assertEqual(10, l.try_get_KC())

  def test_field_getters_not_existing_tags(self):
    l = gfapy.line.Header(["xx:i:13", "VN:Z:HI"])
    self.assertEqual(None, l.zz)
    with self.assertRaises(gfapy.NotFoundError):
      l.try_get_zz()

  def test_field_setters_positional_fields(self):
    l = gfapy.line.segment.Factory(["12", "*", "xx:i:13", "KC:i:1200"])
    with self.assertRaises(gfapy.FormatError):
      l.name = "A\t1"
      l.validate_field("name")
    l.name = "14"
    self.assertEqual("14", l.name)

  def test_field_setters_existing_tags(self):
    l = gfapy.line.Header(["xx:i:13", "VN:Z:HI"], validate = 5)
    self.assertEqual(13, l.xx)
    l.xx = 15
    self.assertEqual(15, l.xx)
    with self.assertRaises(gfapy.FormatError):
      l.xx = "1A"
    l.set_datatype("xx", "Z")
    l.xx = "1A"
    self.assertEqual("HI", l.VN)
    l.VN = "HO"
    self.assertEqual("HO", l.VN)

  def test_field_setters_not_existing_tags(self):
    l = gfapy.line.Header(["xx:i:13", "VN:Z:HI"])
    l.zz="1"
    self.assertEqual("1", l.zz)
    self.assertEqual("Z", gfapy.field.get_default_gfa_tag_datatype(l.zz))
    l.zi=1
    self.assertEqual(1, l.zi)
    self.assertEqual("i", gfapy.field.get_default_gfa_tag_datatype(l.zi))
    l.zf=1.0
    self.assertEqual(1.0, l.zf)
    self.assertEqual("f", gfapy.field.get_default_gfa_tag_datatype(l.zf))
    l.bf=[1.0, 1.0]
    self.assertEqual([1.0, 1.0], l.bf)
    self.assertEqual("B", gfapy.field.get_default_gfa_tag_datatype(l.bf))
    l.bi=[1.0, 1.0]
    self.assertEqual([1, 1], l.bi)
    self.assertEqual("B", gfapy.field.get_default_gfa_tag_datatype(l.bi))
    l.ba=[1.0, 1]
    self.assertEqual([1.0, 1], l.ba)
    self.assertEqual("J", gfapy.field.get_default_gfa_tag_datatype(l.ba))
    l.bh={"a" : 1.0, "b" : 1}
    self.assertEqual({"a" : 1.0, "b" : 1}, gfapy.Line.from_string(str(l)).bh)
    self.assertEqual("J", gfapy.field.get_default_gfa_tag_datatype(l.bh))
    #Assignement of new attributes possible in python.
    #with self.assertRaises(AttributeError):
    #  l.zzz="1"

  def test_add_tag(self):
    l = gfapy.line.Header(["xx:i:13", "VN:Z:HI"])
    self.assertEqual(None, l.xy)
    l.set("xy", "HI")
    self.assertEqual("HI", l.xy)

  def test_to_s(self):
    fields = ["xx:i:13", "VN:Z:HI"]
    l = gfapy.line.Header(fields[:])
    self.assertEqual("\t".join(["H"]+fields), str(l))

  def test_unknown_record_type(self):
    with self.assertRaises(gfapy.TypeError):
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
