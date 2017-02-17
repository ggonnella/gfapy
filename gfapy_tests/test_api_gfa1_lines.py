import gfapy
import unittest

class TestApiGfa1Lines(unittest.TestCase):

  def test_C(self):
    fields=["C","1","+","2","-","12","12M","MQ:i:1232","NM:i:3","ab:Z:abcd"]
    s="\t".join(fields)
    gfapy.Line.from_string(s) # nothing raised
    self.assertEqual(gfapy.line.edge.Containment, gfapy.Line.from_string(s).__class__)
    self.assertEqual(fields[0], gfapy.Line.from_string(s).record_type)
    self.assertEqual(fields[1], gfapy.Line.from_string(s).from_segment)
    self.assertEqual(fields[2], gfapy.Line.from_string(s).from_orient)
    self.assertEqual(fields[3], gfapy.Line.from_string(s).to_segment)
    self.assertEqual(fields[4], gfapy.Line.from_string(s).to_orient)
    self.assertEqual(12, gfapy.Line.from_string(s).pos)
    self.assertEqual([gfapy.CIGAR.Operation(12,"M")], gfapy.Line.from_string(s).overlap)
    self.assertEqual(1232, gfapy.Line.from_string(s).MQ)
    self.assertEqual(3, gfapy.Line.from_string(s).NM)
    self.assertEqual("abcd", gfapy.Line.from_string(s).ab)
    with self.assertRaises(gfapy.FormatError): (str+gfapy.Line.from_string("\tH1"))
    with self.assertRaises(gfapy.FormatError): gfapy.Line.from_string("C\tH")
    with self.assertRaises(gfapy.FormatError):
      f=fields.copy(); f[2]="x"; gfapy.Line.from_string("\t".join(f),vlevel=1)
    with self.assertRaises(gfapy.FormatError):
      f=fields.copy(); f[4]="x"; gfapy.Line.from_string("\t".join(f),vlevel=1)
    with self.assertRaises(gfapy.FormatError):
      f=fields.copy(); f[5]="x"; gfapy.Line.from_string("\t".join(f),vlevel=1)
    with self.assertRaises(gfapy.FormatError):
      f=fields.copy(); f[6]="x"; gfapy.Line.from_string("\t".join(f),vlevel=1)
    with self.assertRaises(gfapy.TypeError):
      f=fields.copy(); f[7]="MQ:Z:1232"; gfapy.Line.from_string("\t".join(f),vlevel=1)
    with self.assertRaises(gfapy.TypeError):
      f=fields.copy(); f[8]="NM:Z:1232"; gfapy.Line.from_string("\t".join(f),vlevel=1)

  def test_L(self):
    fields=["L","1","+","2","-","12M","RC:i:1232","NM:i:3","ab:Z:abcd",
            "FC:i:2321","KC:i:1212","MQ:i:40"]
    s="\t".join(fields)
    gfapy.Line.from_string(s) # nothing raised
    self.assertEqual(gfapy.line.edge.Link, gfapy.Line.from_string(s).__class__)
    self.assertEqual(fields[0], gfapy.Line.from_string(s).record_type)
    self.assertEqual(fields[1], gfapy.Line.from_string(s).from_segment)
    self.assertEqual(fields[2], gfapy.Line.from_string(s).from_orient)
    self.assertEqual(fields[3], gfapy.Line.from_string(s).to_segment)
    self.assertEqual(fields[4], gfapy.Line.from_string(s).to_orient)
    self.assertEqual([gfapy.CIGAR.Operation(12,"M")],
                 gfapy.Line.from_string(s).overlap)
    self.assertEqual(1232, gfapy.Line.from_string(s).RC)
    self.assertEqual(3, gfapy.Line.from_string(s).NM)
    self.assertEqual(2321, gfapy.Line.from_string(s).FC)
    self.assertEqual(1212, gfapy.Line.from_string(s).KC)
    self.assertEqual(40, gfapy.Line.from_string(s).MQ)
    self.assertEqual("abcd", gfapy.Line.from_string(s).ab)
    with self.assertRaises(gfapy.FormatError): (str+gfapy.Line.from_string("\tH1"))
    with self.assertRaises(gfapy.FormatError): gfapy.Line.from_string("L\tH")
    with self.assertRaises(gfapy.FormatError):
      f=fields.copy(); f[2]="x"; gfapy.Line.from_string("\t".join(f),vlevel=1)
    with self.assertRaises(gfapy.FormatError):
      f=fields.copy(); f[4]="x"; gfapy.Line.from_string("\t".join(f),vlevel=1)
    with self.assertRaises(gfapy.FormatError):
      f=fields.copy(); f[5]="x"; gfapy.Line.from_string("\t".join(f),vlevel=1)
    with self.assertRaises(gfapy.TypeError):
      f=fields.copy(); f[6]="RC:Z:1232"; gfapy.Line.from_string("\t".join(f),vlevel=1)
    with self.assertRaises(gfapy.TypeError):
      f=fields.copy(); f[7]="NM:Z:1232"; gfapy.Line.from_string("\t".join(f),vlevel=1)

  def test_L_coords(self):
    g = gfapy.Gfa(version="gfa1")
    g.append("S\t1\t*\tLN:i:100")
    g.append("L\t1\t+\t2\t-\t1M2D10M1I")
    self.assertEqual(["87","100$"], [str(s) for s in g.dovetails[0].from_coords])
    with self.assertRaises(gfapy.ValueError): g.dovetails[0].to_coords
    g.append("S\t2\t*\tLN:i:100")
    self.assertEqual(["88","100$"], [str(s) for s in g.dovetails[0].to_coords])
    g.append("L\t3\t-\t4\t+\t10M2P3D1M")
    self.assertEqual(["0","14"], [str(s) for s in g.dovetails[1].from_coords])
    self.assertEqual(["0","11"], [str(s) for s in g.dovetails[1].to_coords])

  def test_L_other(self):
    l = gfapy.Line.from_string("L\t1\t+\t2\t-\t*")
    self.assertEqual("2", l.other("1"))
    self.assertEqual("1", l.other("2"))
    with self.assertRaises(gfapy.NotFoundError): l.other("0")

  def test_L_circular(self):
    l = gfapy.Line.from_string("L\t1\t+\t2\t-\t*")
    self.assertEqual(False, l.is_circular())
    l = gfapy.Line.from_string("L\t1\t+\t1\t-\t*")
    self.assertEqual(True, l.is_circular())

  def test_S(self):
    fields=["S","1","ACGTCACANNN","RC:i:1232","LN:i:11","ab:Z:abcd",
            "FC:i:2321","KC:i:1212"]
    s="\t".join(fields)
    gfapy.Line.from_string(s) # nothing raised
    self.assertEqual(gfapy.line.segment.GFA1, gfapy.Line.from_string(s).__class__)
    self.assertEqual(fields[0], gfapy.Line.from_string(s).record_type)
    self.assertEqual(fields[1], gfapy.Line.from_string(s).name)
    self.assertEqual(fields[2], gfapy.Line.from_string(s).sequence)
    self.assertEqual(1232, gfapy.Line.from_string(s).RC)
    self.assertEqual(11, gfapy.Line.from_string(s).LN)
    self.assertEqual(2321, gfapy.Line.from_string(s).FC)
    self.assertEqual(1212, gfapy.Line.from_string(s).KC)
    self.assertEqual("abcd", gfapy.Line.from_string(s).ab)
    with self.assertRaises(gfapy.FormatError): (str+gfapy.Line.from_string("\tH1"))
    with self.assertRaises(gfapy.FormatError): gfapy.Line.from_string("S\tH")
    with self.assertRaises(gfapy.FormatError):
      f=fields.copy(); f[2]="!@#?"; gfapy.Line.from_string("\t".join(f),vlevel=1)
    with self.assertRaises(gfapy.TypeError):
      f=fields.copy(); f[3]="RC:Z:1232"; gfapy.Line.from_string("\t".join(f),version="gfa1")
    f=["S","2","ACGTCACANNN","LN:i:3"]
    with self.assertRaises(gfapy.InconsistencyError):
      gfapy.Line.from_string("\t".join(f),vlevel=1, version="gfa1")
    f=["S","2","ACGTCACANNN","LN:i:11"]
    gfapy.Line.from_string("\t".join(f)) # nothing raised
    f=["S","2","*","LN:i:3"]
    gfapy.Line.from_string("\t".join(f)) # nothing raised

  def test_forbidden_segment_names(self):
    gfapy.Line.from_string("S\tA+B\t*") # nothing raised
    gfapy.Line.from_string("S\tA-B\t*") # nothing raised
    gfapy.Line.from_string("S\tA,B\t*") # nothing raised
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line.from_string("S\tA+,B\t*",vlevel=1)
    with self.assertRaises(gfapy.FormatError):
      gfapy.Line.from_string("S\tA-,B\t*",vlevel=1)

  def test_coverage(self):
    l = gfapy.Line.from_string("S\t0\t*\tRC:i:600\tLN:i:100")
    self.assertEqual(6, l.coverage())
    self.assertEqual(6, l.try_get_coverage())
    l = gfapy.Line.from_string("S\t0\t*\tRC:i:600")
    self.assertEqual(None, l.coverage())
    with self.assertRaises(gfapy.NotFoundError): l.try_get_coverage()
    l = gfapy.Line.from_string("S\t0\t*\tLN:i:100")
    self.assertEqual(None, l.coverage())
    with self.assertRaises(gfapy.NotFoundError): l.try_get_coverage()
    l = gfapy.Line.from_string("S\t0\t*\tFC:i:600\tLN:i:100")
    self.assertEqual(None, l.coverage())
    with self.assertRaises(gfapy.NotFoundError): l.try_get_coverage()
    self.assertEqual(6, l.coverage(count_tag="FC"))
    self.assertEqual(6, l.try_get_coverage(count_tag="FC"))

  def test_P(self):
    fields=["P","4","1+,2-,3+","9M2I3D1M,12M","ab:Z:abcd"]
    s="\t".join(fields)
    gfapy.Line.from_string(s) # nothing raised
    self.assertEqual(gfapy.line.group.Path, gfapy.Line.from_string(s).__class__)
    self.assertEqual(fields[0], gfapy.Line.from_string(s).record_type)
    self.assertEqual(fields[1], gfapy.Line.from_string(s).path_name)
    self.assertEqual([gfapy.OrientedLine("1","+"),gfapy.OrientedLine("2","-"),
        gfapy.OrientedLine("3","+")],
                 gfapy.Line.from_string(s).segment_names)
    self.assertEqual([[gfapy.CIGAR.Operation(9,"M"),
                   gfapy.CIGAR.Operation(2,"I"),
                   gfapy.CIGAR.Operation(3,"D"),
                   gfapy.CIGAR.Operation(1,"M")],
                  [gfapy.CIGAR.Operation(12,"M")]],
                 gfapy.Line.from_string(s).overlaps)
    self.assertEqual("abcd", gfapy.Line.from_string(s).ab)
    with self.assertRaises(gfapy.FormatError): (str+gfapy.Line.from_string("\tH1"))
    with self.assertRaises(gfapy.FormatError): gfapy.Line.from_string("P\tH")
    with self.assertRaises(gfapy.FormatError):
      f=fields.copy(); f[2]="1,2,3"; gfapy.Line.from_string("\t".join(f),vlevel=1)
    with self.assertRaises(gfapy.InconsistencyError):
      f=fields.copy(); f[2]="1+,2+"; f[3]="9M,12M,3M"
      gfapy.Line.from_string("\t".join(f),vlevel=1)
      f=fields.copy(); f[3]="*,*";
      gfapy.Line.from_string("\t".join(f),vlevel=1)
      f=fields.copy(); f[3]="9M2I3D1M,12M,12M";
      gfapy.Line.from_string("\t".join(f),vlevel=3)
      f=fields.copy(); f[3]="*";
      gfapy.Line.from_string("\t".join(f),vlevel=1)
    with self.assertRaises(gfapy.FormatError):
      f=fields.copy(); f[3]="12,12"; gfapy.Line.from_string("\t".join(f),vlevel=1)
    with self.assertRaises(gfapy.FormatError):
      f=fields.copy(); f[3]="12M|12M"; gfapy.Line.from_string("\t".join(f),vlevel=1)

