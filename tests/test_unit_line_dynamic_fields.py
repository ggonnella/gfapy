import unittest
import gfapy

class TestUnitLineDynamicFields(unittest.TestCase):

  def test_respond_to(self):
    l = gfapy.line.edge.Link(["L", "1", "+", "2", "-", "*", "zz:Z:yes", "KC:i:100"])
    # record_type
    self.assertTrue(hasattr(l, "record_type"))
    # reqfields
    self.assertTrue(hasattr(l, "from_segment"))
    self.assertIsInstance(object.__getattribute__(l, "from_segment"),
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

  def test_field_getters_positional_fields(self):
    l = gfapy.Line(["S", "12", "*", "xx:i:13", "KC:i:10"])
    self.assertEqual("12", l.name)
    with self.assertRaises(AttributeError):
      l.zzz

  def test_field_getters_existing_tags(self):
    l = gfapy.Line(["S", "12", "*", "xx:i:13", "KC:i:10"])
    self.assertEqual("xx", sorted(l.tagnames)[1])
    self.assertEqual("13", l.field_to_s("xx"))
    self.assertEqual(13, l.xx)
    self.assertEqual(13, l.try_get_xx())
    self.assertEqual("10", l.field_to_s("KC"))
    self.assertEqual(10, l.KC)
    self.assertEqual(10, l.try_get_KC())

  def test_field_getters_not_existing_tags(self):
    l = gfapy.line.Header(["H", "xx:i:13", "VN:Z:HI"])
    self.assertEqual(None, l.zz)
    with self.assertRaises(gfapy.NotFoundError):
      l.try_get_zz()

  def test_field_setters_positional_fields(self):
    l = gfapy.Line(["S", "12", "*", "xx:i:13", "KC:i:1200"])
    with self.assertRaises(gfapy.FormatError):
      l.name = "A\t1"
      l.validate_field("name")
    l.name = "14"
    self.assertEqual("14", l.name)

  def test_field_setters_existing_tags(self):
    l = gfapy.line.Header(["H", "xx:i:13", "VN:Z:HI"], vlevel = 3)
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
    l = gfapy.line.Header(["H", "xx:i:13", "VN:Z:HI"])
    l.zz="1"
    self.assertEqual("1", l.zz)
    self.assertEqual("Z", gfapy.Field._get_default_gfa_tag_datatype(l.zz))
    l.zi=1
    self.assertEqual(1, l.zi)
    self.assertEqual("i", gfapy.Field._get_default_gfa_tag_datatype(l.zi))
    l.zf=1.0
    self.assertEqual(1.0, l.zf)
    self.assertEqual("f", gfapy.Field._get_default_gfa_tag_datatype(l.zf))
    l.bf=[1.0, 1.0]
    self.assertEqual([1.0, 1.0], l.bf)
    self.assertEqual("B", gfapy.Field._get_default_gfa_tag_datatype(l.bf))
    l.bi=[1.0, 1.0]
    self.assertEqual([1, 1], l.bi)
    self.assertEqual("B", gfapy.Field._get_default_gfa_tag_datatype(l.bi))
    l.ba=[1.0, 1]
    self.assertEqual([1.0, 1], l.ba)
    self.assertEqual("J", gfapy.Field._get_default_gfa_tag_datatype(l.ba))
    l.bh={"a" : 1.0, "b" : 1}
    self.assertEqual({"a" : 1.0, "b" : 1}, gfapy.Line(str(l)).bh)
    self.assertEqual("J", gfapy.Field._get_default_gfa_tag_datatype(l.bh))
    #Assignement of new attributes possible in python.
    #with self.assertRaises(AttributeError):
    #  l.zzz="1"

