import unittest
import gfapy

class TestApiComments(unittest.TestCase):

  def test_initialize(self):
   l = gfapy.line.Comment("# hallo")
   self.assertEqual("# hallo", str(l))
   l = gfapy.line.Comment(["#", "hallo", "\t"])
   self.assertEqual("#\thallo", str(l))

  def test_fields(self):
   l = gfapy.line.Comment("# hallo")
   self.assertEqual("hallo", l.content)
   self.assertEqual(" ", l.spacer)
   l.content = "hello"
   self.assertEqual("hello", l.content)
   self.assertEqual("# hello", str(l))
   l.spacer = "  "
   self.assertEqual("hello", l.content)
   self.assertEqual("#  hello", str(l))

  def test_validation(self):
   with self.assertRaises(gfapy.FormatError):
     gfapy.line.Comment(["#", "hallo\nhallo"])
   with self.assertRaises(gfapy.FormatError):
     gfapy.line.Comment(["#", "hallo", "\n"])
   gfapy.line.Comment(["#", "hallo", "\n"], vlevel=0) # nothing raised
   l = gfapy.line.Comment(["#", "hallo"])
   l.content = "hallo\n" # nothing raised
   with self.assertRaises(gfapy.FormatError): str(l)
   l.content = "hallo"
   str(l) # nothing raised
   l.spacer = "\n" # nothing raised
   with self.assertRaises(gfapy.FormatError): str(l)
   l = gfapy.line.Comment(["#", "hallo"], vlevel=3)
   with self.assertRaises(gfapy.FormatError): l.content = "hallo\n"
   with self.assertRaises(gfapy.FormatError): l.spacer = "\n"

  def test_from_string(self):
    s = "# this is a comment"
    l = gfapy.Line(s)
    self.assertEqual(gfapy.line.Comment, l.__class__)
    self.assertEqual(s[2:], l.content)
    self.assertEqual(" ", l.spacer)
    s = "#this is another comment"
    l = gfapy.Line(s)
    self.assertEqual(gfapy.line.Comment, l.__class__)
    self.assertEqual(s[1:], l.content)
    self.assertEqual("", l.spacer)
    s = "#\t and this too"
    l = gfapy.Line(s)
    self.assertEqual(gfapy.line.Comment, l.__class__)
    self.assertEqual(s[3:], l.content)
    self.assertEqual(s[1:3], l.spacer)
    s = "#: and this too"
    l = gfapy.Line(s)
    self.assertEqual(gfapy.line.Comment, l.__class__)
    self.assertEqual(s[1:], l.content)
    self.assertEqual("", l.spacer)

  def test_to_s(self):
    s = "# this is a comment"
    l = gfapy.Line(s)
    self.assertEqual(s, str(l))
    s = "#this is another\tcomment"
    l = gfapy.Line(s)
    self.assertEqual(s, str(l))
    s = "#this is another\tcomment"
    l = gfapy.Line(s)
    l.spacer = " "
    self.assertEqual("# "+s[1:], str(l))

  def test_tags(self):
    with self.assertRaises(gfapy.ValueError):
      gfapy.line.Comment(["#", "hallo", " ", "zz:Z:hallo"])
    l = gfapy.Line("# hallo zz:Z:hallo")
    self.assertEqual("hallo zz:Z:hallo", l.content)
    self.assertEqual(None, l.zz)
    with self.assertRaises(gfapy.RuntimeError): l.zz = 1
    with self.assertRaises(gfapy.RuntimeError): l.set("zz", 1)
    self.assertEqual(None, l.get("zz"))

  def test_to_gfa1(self):
    s = "# this is a comment"
    l = gfapy.Line(s,version="gfa2")
    self.assertEqual(gfapy.line.Comment, l.__class__)
    self.assertEqual("gfa2", l.version)
    self.assertEqual(s, str(l))
    self.assertEqual("gfa2", l.to_gfa2().version)
    self.assertEqual(s, str(l.to_gfa2()))
    self.assertEqual("gfa1", l.to_gfa1().version)
    self.assertEqual(s, str(l.to_gfa1()))

  def test_to_gfa2(self):
    s = "# this is a comment"
    l = gfapy.Line(s,version="gfa1")
    self.assertEqual(gfapy.line.Comment, l.__class__)
    self.assertEqual("gfa1", l.version)
    self.assertEqual(s, str(l))
    self.assertEqual("gfa1", l.to_gfa1().version)
    self.assertEqual(s, str(l.to_gfa1()))
    self.assertEqual("gfa2", l.to_gfa2().version)
    self.assertEqual(s, str(l.to_gfa2()))

  def test_rgfa_comments(self):
    gfa = gfapy.Gfa()
    c1 = "#this is a comment"
    c2 = "# this is also a comment"
    c3 = "#and \tthis too!"
    gfa.add_line(c1) # nothing raised
    gfa.add_line(c2) # nothing raised
    gfa.add_line(c3) # nothing raised
    self.assertEqual([c1,c2,c3], [str(x) for x in gfa.comments])
    self.assertEqual(c1, str(gfa.comments[0]))
    gfa.rm(gfa.comments[0])
    self.assertEqual([c2,c3], [str(x) for x in gfa.comments])
    gfa.comments[0].disconnect()
    self.assertEqual([c3], [str(x) for x in gfa.comments])
