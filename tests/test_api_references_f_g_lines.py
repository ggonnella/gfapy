import gfapy
import unittest

class TestAPIReferencesFGLines(unittest.TestCase):

  def test_fragments_references(self):
    g = gfapy.Gfa()
    f = gfapy.Line("F\ta\tf+\t0\t200\t281\t502$\t*")
    self.assertEqual("a", f.sid)
    self.assertEqual(gfapy.OrientedLine("f","+"), f.external)
    sa = gfapy.Line("S\ta\t100\t*")
    g.append(sa)
    g.append(f)
    self.assertEqual(sa, f.sid)
    f.disconnect()
    self.assertEqual("a", f.sid)
    # disconnection of segment cascades on fragments
    g.append(f)
    assert(f.is_connected())
    self.assertEqual(sa, f.sid)
    sa.disconnect()
    assert(not f.is_connected())
    self.assertEqual("a", f.sid)

  def test_fragments_backreferences(self):
    g = gfapy.Gfa()
    f1 = gfapy.Line("F\ta\tf+\t0\t200\t281\t502$\t*")
    f2 = gfapy.Line("F\ta\tf+\t240\t440$\t0\t210\t*")
    sa = gfapy.Line("S\ta\t100\t*")
    g.append(sa)
    g.append(f1)
    g.append(f2)
    self.assertEqual([f1,f2], sa.fragments)
    # disconnection effects
    f1.disconnect()
    self.assertEqual([f2], sa.fragments)
    sa.disconnect()
    self.assertEqual([], sa.fragments)

  def test_gap_references(self):
    g = gfapy.Gfa()
    gap = gfapy.Line("G\t*\ta+\tb+\t90\t*")
    self.assertEqual(gfapy.OrientedLine("a","+"), gap.sid1)
    self.assertEqual(gfapy.OrientedLine("b","+"), gap.sid2)
    sa = gfapy.Line("S\ta\t100\t*");
    g.append(sa)
    sb = gfapy.Line("S\tb\t100\t*");
    g.append(sb)
    g.append(gap)
    self.assertEqual(sa, gap.sid1.line)
    self.assertEqual(sb, gap.sid2.line)
    gap.disconnect()
    self.assertEqual("a", gap.sid1.line)
    self.assertEqual("b", gap.sid2.line)
    # disconnection of segment cascades on gaps
    g.append(gap)
    assert(gap.is_connected())
    self.assertEqual(sa, gap.sid1.line)
    sa.disconnect()
    assert(not gap.is_connected())
    self.assertEqual("a", gap.sid1.line)

  def test_gaps_backreferences(self):
    g = gfapy.Gfa()
    sa = gfapy.Line("S\ta\t100\t*")
    g.append(sa)
    # gaps
    s = {}
    gap = {}
    for name in ["b", "c", "d", "e", "f", "g", "h", "i"]:
      s[name] = gfapy.Line("S\t{}\t100\t*".format(name))
      g.append(s[name])
    for name in \
      ["a+b+", "a+c-", "a-d+", "a-e-", "f+a+", "g+a-", "h-a+", "i-a-"]:
      gap[name] = gfapy.Line("\t".join(
                                   ["G","*",name[0:2],name[2:4],"200","*"]))
      g.append(gap[name])
    # gaps_[LR]()
    self.assertEqual([gap["a-d+"], gap["a-e-"], gap["f+a+"], gap["h-a+"]],
                 sa.gaps_L)
    self.assertEqual([gap["a+b+"], gap["a+c-"], gap["g+a-"], gap["i-a-"]],
                 sa.gaps_R)
    # gaps()
    self.assertEqual(sa.gaps_L, sa.gaps_of_end("L"))
    self.assertEqual(sa.gaps_R, sa.gaps_of_end("R"))
    self.assertEqual(sa.gaps_L + sa.gaps_R, sa.gaps)
    # disconnection effects
    gap["a-d+"].disconnect()
    self.assertEqual([gap["a-e-"], gap["f+a+"], gap["h-a+"]], sa.gaps_L)
    sa.disconnect()
    self.assertEqual([], sa.gaps_L)
    self.assertEqual([], sa.gaps_R)
    self.assertEqual([], sa.gaps_of_end("L"))
    self.assertEqual([], sa.gaps_of_end("R"))
    self.assertEqual([], sa.gaps)

