import gfapy
import unittest

class TestApiCustomRecords(unittest.TestCase):

  def test_from_string(self):
    str1 = "X\tthis is a\tcustom line"
    l1 = gfapy.Line(str1)
    self.assertEqual(gfapy.line.CustomRecord, l1.__class__)
    self.assertEqual("X", l1.record_type)
    self.assertEqual("this is a", l1.field1)
    self.assertEqual("custom line", l1.field2)

  def test_from_string_with_tags(self):
    str2 = "XX\txx:i:2\txxxxxx\txx:i:1"
    l2 = gfapy.Line(str2)
    self.assertEqual(gfapy.line.CustomRecord, l2.__class__)
    self.assertEqual("XX", l2.record_type)
    self.assertEqual("xx:i:2", l2.field1)
    self.assertEqual("xxxxxx", l2.field2)
    with self.assertRaises(AttributeError): l2.field3
    self.assertEqual(1, l2.xx)
    l2.xx = 3
    self.assertEqual(3, l2.xx)
    l2.field1 = "blabla"
    self.assertEqual("blabla", l2.field1)

  def test_to_s(self):
    str1 = "X\tthis is a\tcustom line"
    self.assertEqual(str1, str(gfapy.Line(str1)))
    str2 = "XX\txx:i:2\txxxxxx\txx:i:1"
    self.assertEqual(str2, str(gfapy.Line(str2)))

  def test_add_custom_records(self):
    gfa = gfapy.Gfa(version="gfa2")
    x1 = "X\tthis is a custom record"
    gfa.append(x1) # nothing raised
    self.assertEqual(["X"], gfa.custom_record_keys)
    self.assertEqual([x1], [str(x) for x in gfa.custom_records_of_type("X")])

  def test_delete_custom_records(self):
    gfa = gfapy.Gfa(version="gfa2")
    c = "X\tThis is a custom_record"
    gfa.append(c)
    self.assertEqual([c], [str(x) for x in gfa.custom_records_of_type("X")])
    for x in gfa.custom_records_of_type("X"): x.disconnect()
    self.assertEqual([], gfa.custom_records_of_type("X"))

  def test_custom_records(self):
    x = ["X\tVN:Z:1.0", "Y\ttesttesttest"]
    self.assertEqual(x[0], str(gfapy.Gfa(x).custom_records_of_type("X")[0]))
    self.assertEqual(x[1], str(gfapy.Gfa(x).custom_records_of_type("Y")[0]))

