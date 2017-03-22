import unittest
import gfapy

class TestUnitLineCloning(unittest.TestCase):

  def test_clone_tags(self):
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

  def test_clone_deep_string(self):
    s = gfapy.Line("S\t1\tCAGCTTG")
    s_clone = s.clone()
    s_clone.sequence += "CCC"
    self.assertNotEqual(s_clone.sequence, s.sequence)

  def test_clone_deep_posfield_array(self):
    u = gfapy.Line("U\t*\t1 2 3")
    u_clone = u.clone()
    self.assertEqual(u_clone.items, u.items)
    self.assertNotEqual(id(u_clone.items), id(u.items))
    u_clone.items.append("4")
    self.assertNotEqual(u_clone.items, u.items)

  def test_clone_deep_J_field(self):
    h = gfapy.Line("H\txx:J:[1,2,3]")
    h_clone = h.clone()
    self.assertEqual(h_clone.xx, h.xx)
    self.assertNotEqual(id(h_clone.xx), id(h.xx))
    h_clone.xx[0] += 1
    self.assertNotEqual(h_clone.xx, h.xx)

  def test_clone_disconnected(self):
    g = gfapy.Gfa()
    sA = gfapy.Line("S\tA\t7\tCAGCTTG")
    u = gfapy.Line("U\tU12\tA B C")
    g.add_line(sA)
    g.add_line(u)
    assert(u.is_connected())
    self.assertEqual([u], sA.sets)
    self.assertEqual([u], g.sets)
    u_clone = u.clone()
    assert(not u_clone.is_connected())
    self.assertEqual([u], sA.sets)
    self.assertEqual([u], g.sets)
    assert(all(isinstance(i,gfapy.Line) for i in u.items))
    assert(not any(isinstance(i,gfapy.Line) for i in u_clone.items))
    self.assertEqual(["A", "B", "C"], [e.name for e in u.items])
    self.assertEqual(["A", "B", "C"], u_clone.items)
