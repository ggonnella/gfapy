import gfapy
import unittest
from .extension import *

class TestAPIExtensions(unittest.TestCase):

  def test_extensions(self):
    g = gfapy.Gfa(version="gfa2", vlevel=0)
    MetagenomicAssignment(["M", "*","N12","C","SC:i:20"])
    sA = gfapy.Line("S\tA\t1000\t*")
    g.append(sA)
    tB12 = gfapy.Line("T\tB12_c")
    g.append(tB12)
    m1 = gfapy.Line("M\t1\ttaxon:123\tA\tSC:i:40\txx:Z:cjaks536")
    g.append(m1)
    m2 = gfapy.Line("M\t2\ttaxon:123\tB\txx:Z:cga5r5cs")
    g.append(m2)
    sB = gfapy.Line("S\tB\t1000\t*")
    g.append(sB)
    mx = gfapy.Line("M\t*\tB12_c\tB\tSC:i:20")
    g.append(mx)
    t123 = gfapy.Line(
      "T\ttaxon:123\tUL:Z:http://www.taxon123.com")
    g.append(t123)
    self.assertEqual(MetagenomicAssignment, m1.__class__)
    self.assertEqual(Taxon, tB12.__class__)
    self.assertEqual("1", m1.mid)
    assert(gfapy.is_placeholder(mx.mid))
    self.assertEqual(t123, m1.tid)
    self.assertEqual(sA, m1.sid)
    self.assertEqual("cjaks536", m1.xx)
    self.assertEqual([m2,mx], sB.metagenomic_assignments)
    self.assertEqual([m1,m2], t123.metagenomic_assignments)
    self.assertEqual("taxon:123", t123.tid)
    self.assertEqual("http://www.taxon123.com", t123.UL)

