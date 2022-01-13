import unittest
import gfapy

class TestUnitLineConnection(unittest.TestCase):

  def test_connected_and_gfa(self):
    s1 = gfapy.Line("S\t1\tACCAT")
    assert(not s1.is_connected())
    self.assertEqual(None, s1.gfa)
    g = gfapy.Gfa()
    g.append(s1)
    assert(s1.is_connected())
    assert(g is s1.gfa)

  def test_connect(self):
    s2 = gfapy.Line("S\t2\tACCAT")
    assert(not s2.is_connected())
    self.assertEqual(None, s2.gfa)
    g = gfapy.Gfa()
    s2.connect(g)
    assert(s2.is_connected())
    assert(g is s2.gfa)

  def test_connect_registers_line(self):
    s2 = gfapy.Line("S\t2\tACCAT")
    g = gfapy.Gfa()
    self.assertEqual([], g.segments)
    s2.connect(g)
    self.assertEqual([s2], g.segments)

  def test_disconnect(self):
    s1 = gfapy.Line("S\t1\tACCAT")
    g = gfapy.Gfa()
    g.append(s1)
    assert(s1.is_connected())
    assert(g is s1.gfa)
    s1.disconnect()
    assert(not s1.is_connected())
    self.assertEqual(None, s1.gfa)

  def test_disconnect_unregisters_line(self):
    s1 = gfapy.Line("S\t1\tACCAT")
    g = gfapy.Gfa()
    g.append(s1)
    self.assertEqual([s1], g.segments)
    s1.disconnect()
    self.assertEqual([], g.segments)

  def test_disconnect_removes_field_backreferences(self):
    s1 = gfapy.Line("S\t1\tACCAT")
    l = gfapy.Line("L\t1\t+\t2\t-\t*")
    g = gfapy.Gfa()
    g.append(s1)
    g.append(l)
    self.assertEqual([l], s1.dovetails)
    l.disconnect()
    self.assertEqual([], s1.dovetails)

  def test_disconnect_removes_field_references(self):
    s1 = gfapy.Line("S\t1\tACCAT")
    l = gfapy.Line("L\t1\t+\t2\t-\t*")
    g = gfapy.Gfa()
    g.append(s1)
    g.append(l)
    assert(l.get("from_segment") is s1)
    l.disconnect()
    assert(not l.get("from_segment") is s1)
    self.assertEqual("1", l.get("from_segment"))

  def test_disconnect_disconnects_depent_lines(self):
    s1 = gfapy.Line("S\t1\tACCAT")
    l = gfapy.Line("L\t1\t+\t2\t-\t*")
    g = gfapy.Gfa()
    g.append(s1)
    g.append(l)
    assert(l.is_connected())
    s1.disconnect()
    assert(not l.is_connected())

  def test_disconnect_removes_nonfield_backreferences(self):
    s1 = gfapy.Line("S\t1\tACCAT")
    s2 = gfapy.Line("S\t2\tCATGG")
    s3 = gfapy.Line("S\t3\tTGGAA")
    l12 = gfapy.Line("L\t1\t+\t2\t+\t*")
    l23 = gfapy.Line("L\t2\t+\t3\t+\t*")
    p4 = gfapy.Line("P\t4\t1+,2+,3+\t*")
    g = gfapy.Gfa()
    for line in [s1, s2, s3, l12, l23, p4]:
      g.append(line)
    self.assertEqual([p4], l12.paths)
    p4.disconnect()
    self.assertEqual([], l12.paths)

  def test_disconnect_removes_nonfield_references(self):
    s1 = gfapy.Line("S\t1\tACCAT")
    s2 = gfapy.Line("S\t2\tCATGG")
    s3 = gfapy.Line("S\t3\tTGGAA")
    l12 = gfapy.Line("L\t1\t+\t2\t+\t*")
    l23 = gfapy.Line("L\t2\t+\t3\t+\t*")
    p4 = gfapy.Line("P\t4\t1+,2+,3+\t*")
    g = gfapy.Gfa()
    for line in [s1, s2, s3, l12, l23, p4]:
      g.append(line)
    self.assertEqual([gfapy.OrientedLine(l12,"+"),gfapy.OrientedLine(l23,"+")], p4.links)
    p4.disconnect()
    self.assertEqual([], p4.links)

  def test_add_reference(self):
    s1 = gfapy.Line("S\t1\tACCAT")
    self.assertEqual([], s1.gaps_L)
    s1._add_reference("X", "gaps_L")
    self.assertEqual(["X"], s1.gaps_L)
    s1._add_reference("Y", "gaps_L")
    self.assertEqual(["X", "Y"], s1.gaps_L)
    s1._add_reference("Z", "gaps_L", append=False)
    self.assertEqual(["Z", "X", "Y"], s1.gaps_L)

  def test_delete_reference(self):
    s1 = gfapy.Line("S\t1\tACCAT")
    s1._add_reference("A", "gaps_L")
    s1._add_reference("B", "gaps_L")
    s1._add_reference("C", "gaps_L")
    s1._add_reference("D", "gaps_L")
    s1._add_reference("E", "gaps_L")
    self.assertEqual(["A", "B", "C", "D", "E"], s1.gaps_L)
    s1._delete_reference("C", "gaps_L")
    self.assertEqual(["A", "B", "D", "E"], s1.gaps_L)
    s1._delete_first_reference("gaps_L")
    self.assertEqual(["B", "D", "E"], s1.gaps_L)
    s1._delete_last_reference("gaps_L")
    self.assertEqual(["B", "D"], s1.gaps_L)

  def test_update_references(self):
    s1 = gfapy.Line("S\t1\tACCAT")
    gA = gfapy.line.Gap({})
    gnewA = gfapy.line.Gap({})
    gB = gfapy.line.Gap({})
    gC = gfapy.line.Gap({})
    gD = gfapy.line.Gap({})
    gE = gfapy.line.Gap({})
    gX = gfapy.line.Gap({})
    s1._add_reference(gA, "gaps_L")
    s1._add_reference(gB, "gaps_L")
    s1._add_reference(gC, "gaps_L")
    s1._add_reference(gD, "gaps_L")
    s1._add_reference(gE, "gaps_L")
    self.assertEqual([gA, gB, gC, gD, gE], s1.gaps_L)
    s1._update_references(gA, gnewA, "sid1")
    self.assertEqual([gnewA, gB, gC, gD, gE], s1.gaps_L)
    s1._update_references(gX, "newX", "sid1")
    self.assertEqual([gnewA, gB, gC, gD, gE], s1.gaps_L)
    s1._update_references(gB, None, "sid1")
    self.assertEqual([gnewA, gC, gD, gE], s1.gaps_L)

