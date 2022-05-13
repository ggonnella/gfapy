import gfapy
import unittest

class TestAPIGfaBasics(unittest.TestCase):

  def test_initialize(self):
    gfapy.Gfa() # nothing raised
    gfa = gfapy.Gfa()
    self.assertEqual(gfapy.Gfa, gfa.__class__)

  def test_version_empty(self):
    gfa = gfapy.Gfa()
    self.assertIsNone(gfa.version)
    gfa = gfapy.Gfa(version="gfa1")
    self.assertEqual("gfa1", gfa.version)
    gfa = gfapy.Gfa(version="gfa2")
    self.assertEqual("gfa2", gfa.version)
    with self.assertRaises(gfapy.VersionError): gfapy.Gfa(version="0.0")

  def test_validate(self):
    gfa = gfapy.Gfa(version="gfa1")
    gfa.append("S\t1\t*")
    gfa.validate() # nothing raised
    gfa.append("L\t1\t+\t2\t-\t*")
    with self.assertRaises(gfapy.NotFoundError): gfa.validate()
    gfa.append("S\t2\t*")
    gfa.validate() # nothing raised
    gfa.append("P\t3\t1+,4-\t*")
    with self.assertRaises(gfapy.NotFoundError): gfa.validate()
    gfa.append("S\t4\t*")
    with self.assertRaises(gfapy.NotFoundError): gfa.validate()
    gfa.append("L\t4\t+\t1\t-\t*")
    gfa.validate() # nothing raised

  def test_to_s(self):
    lines = ["H\tVN:Z:1.0","S\t1\t*","S\t2\t*","S\t3\t*",
     "L\t1\t+\t2\t-\t*","C\t1\t+\t3\t-\t12\t*","P\t4\t1+,2-\t*"]
    gfa = gfapy.Gfa()
    for l in lines: gfa.append(l)
    self.assertEqual(set(lines), set(str(gfa).split("\n")))

  def test_from_file(self):
    filename = "tests/testdata/example1.gfa"
    gfa = gfapy.Gfa.from_file(filename)
    assert(gfa)
    gfa_lines = str(gfa).split("\n")
    line_no = 0
    with open(filename) as f:
      for line in f:
        line = line.rstrip()
        self.assertEqual(gfa_lines[line_no], line)
        line_no += 1

  def test_from_file_ignore_sequences(self):
    filename1 = "tests/testdata/sample.gfa"
    filename2 = "tests/testdata/sample_wo_seqs.gfa"
    gfa = gfapy.Gfa.from_file(filename1, ignore_sequences = True)
    assert(gfa)
    gfa_lines = str(gfa).split("\n")
    line_no = 0
    with open(filename2) as f:
      for line in f:
        line = line.rstrip()
        self.assertEqual(gfa_lines[line_no], line)
        line_no += 1

  #def test_to_file(self):
  #  filename = "tests/testdata/example1.gfa"
  #  gfa = gfapy.Gfa.from_file(filename)
  #  tmp = Tempfile("example1")
  #  gfa.to_file(tmp.path)
  #  tmp.rewind
  #  self.assertEqual(IO.read(filename), IO.read(tmp))

  def test_from_string(self):
    lines = ["H\tVN:Z:1.0","S\t1\t*","S\t2\t*","S\t3\t*",
     "L\t1\t+\t2\t-\t*","C\t1\t+\t3\t-\t12\t*","P\t4\t1+,2-\t*"]
    gfa1 = gfapy.Gfa()
    for l in lines: gfa1.append(l)
    gfa2 = gfapy.Gfa("\n".join(lines))
    assert(gfa2)
    self.assertEqual(gfapy.Gfa, gfa2.__class__)
    self.assertEqual(str(gfa1), str(gfa2))

  def test_from_list(self):
    lines = ["H\tVN:Z:1.0","S\t1\t*","S\t2\t*","S\t3\t*",
     "L\t1\t+\t2\t-\t*","C\t1\t+\t3\t-\t12\t*","P\t4\t1+,2-\t*"]
    gfa1 = gfapy.Gfa()
    for l in lines: gfa1.append(l)
    gfa2 = gfapy.Gfa(lines)
    assert(gfa2)
    self.assertEqual(gfapy.Gfa, gfa2.__class__)
    self.assertEqual(str(gfa1), str(gfa2))

