import gfapy
import unittest

class TestLineLink(unittest.TestCase):

  def test_from_string(self):
    fields=["L","1","+","2","-","12M","RC:i:1232","NM:i:3","ab:Z:abcd",
            "FC:i:2321","KC:i:1212","MQ:i:40"]
    string = "\t".join(fields)
    gfapy.Line(string)
    self.assertIsInstance(gfapy.Line(string), gfapy.line.edge.Link)
    self.assertEqual(str(fields[0]), gfapy.Line(string).record_type)
    self.assertEqual(str(fields[1]), gfapy.Line(string).from_segment)
    self.assertEqual(str(fields[2]), gfapy.Line(string).from_orient)
    self.assertEqual(str(fields[3]), gfapy.Line(string).to_segment)
    self.assertEqual(str(fields[4]), gfapy.Line(string).to_orient)
    self.assertEqual([gfapy.alignment.CIGAR.Operation(12, "M")],
                      gfapy.Line(string).overlap)
    self.assertEqual(1232, gfapy.Line(string).RC)
    self.assertEqual(3, gfapy.Line(string).NM)
    self.assertEqual(2321, gfapy.Line(string).FC)
    self.assertEqual(1212, gfapy.Line(string).KC)
    self.assertEqual(40, gfapy.Line(string).MQ)
    self.assertEqual("abcd", gfapy.Line(string).ab)
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line((string+"\tH1"))
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line("L\tH")
    with self.assertRaises(gfapy.FormatError):
      f=fields[:]
      f[2]="x"
      gfapy.Line("\t".join(f), vlevel = 2)
    with self.assertRaises(gfapy.FormatError):
      f=fields[:]
      f[4]="x"
      gfapy.Line("\t".join(f), vlevel = 2)
    with self.assertRaises(gfapy.FormatError):
      f=fields[:]
      f[5]="x"
      gfapy.Line("\t".join(f), vlevel = 2)
    with self.assertRaises(gfapy.TypeError):
      f=fields[:]
      f[6]="RC:Z:1232"
      gfapy.Line("\t".join(f), vlevel = 2)
    with self.assertRaises(gfapy.TypeError):
      f=fields[:]
      f[7]="NM:Z:1232"
      gfapy.Line("\t".join(f), vlevel = 2)

  #TODO
  #def test_coords
  #  g = RGFA.new(version: :gfa1)
  #  g << "S\t1\t*\tLN:i:100"
  #  g << "L\t1\t+\t2\t-\t1M2D10M1I"
  #  assert_equal([87,100], g.links[0].from_coords)
  #  assert_raises(RGFA::ValueError) {g.links[0].to_coords}
  #  g << "S\t2\t*\tLN:i:100"
  #  assert_equal([88,100], g.links[0].to_coords)
  #  g << "L\t3\t-\t4\t+\t10M2P3D1M"
  #  assert_equal([0,14], g.links[1].from_coords)
  #  assert_equal([0,11], g.links[1].to_coords)
  #end

  #def test_to_gfa2
  #  g = RGFA.new(version: :gfa1)
  #  g << "S\t1\t*\tLN:i:100"
  #  g << "S\t2\t*\tLN:i:100"
  #  g << "S\t3\t*\tLN:i:100"
  #  g << "S\t4\t*\tLN:i:100"
  #  g << "L\t1\t+\t2\t+\t10M"
  #  g << "L\t1\t-\t2\t-\t20M"
  #  g << "L\t3\t-\t4\t+\t30M"
  #  g << "L\t3\t+\t4\t-\t40M"
  #  assert_equal("E	*	1+	2+	90	100$	0	10	10M",
  #               g.links[0].to_gfa2_s)
  #  assert_equal("E	*	1-	2-	0	20	80	100$	20M",
  #               g.links[1].to_gfa2_s)
  #  assert_equal("E	*	3-	4+	0	30	0	30	30M",
  #               g.links[2].to_gfa2_s)
  #  assert_equal("E	*	3+	4-	60	100$	60	100$	40M",
  #               g.links[3].to_gfa2_s)
  #  assert_equal(RGFA::Line::Edge::Link, g.links[0].to_gfa1.class)
  #  assert_equal(RGFA::Line::Edge::GFA2, g.links[0].to_gfa2.class)
  #end
