import unittest
import gfapy

class TestApiTags(unittest.TestCase):

  def test_predefined_tags(self):
    # correct type:
    gfapy.line.Header(["H", "VN:Z:1"], vlevel=3) # nothing raised
    # custom tags with the same letters as predefined tags but lower case
    gfapy.line.Header(["H", "vn:i:1"], vlevel=3) # nothing raised
    # wrong type
    gfapy.line.Header(["H", "VN:i:1"], vlevel=0) # nothing raised
    for level in [1,2,3]:
      self.assertRaises(gfapy.TypeError,
        gfapy.line.Header, ["H", "VN:i:1"], vlevel=level)

  def test_custom_tags(self):
    for version in ["gfa1","gfa2"]:
      for tagname in ["ZZ","Z1","Zz","zz"]:
        for level in [0,1,2,3]:
          tag = "{}:Z:1".format(tagname)
          gfapy.line.Header(["H", tag], version=version, vlevel=level) # nothing raised
          gfapy.Line("H\t"+tag, version=version, vlevel=level) # nothing raised
          gfapy.Gfa("H\t"+tag, version=version, vlevel=level) # nothing raised

  def test_wrong_tag_format(self):
    self.assertRaises(gfapy.FormatError, gfapy.line.Header, ["H", "VN i:1"])
    self.assertRaises(gfapy.FormatError, gfapy.line.Header, ["H", "vna:i:1"])
    self.assertRaises(gfapy.FormatError, gfapy.line.Header, ["H", "VN:ZZ:1"])
    # the content can include :, so four : are e.g. not an error
    self.assertEqual("1:1:1", gfapy.line.Header(["H", "VN:Z:1:1:1"]).VN)

  def test_wrong_tag_data(self):
    # validation level 0
    # - some wrong data passes through
    gfapy.line.Header(["H", "zz:B:i,1,1,A"], vlevel=0) # nothing raised
    gfapy.line.Header(["H", "zz:Z:i,\t1,1,A"], vlevel=0) # nothing raised
    # - some errors are catched
    self.assertRaises(gfapy.FormatError, gfapy.line.Header, ["H", "zz:i:1A"], vlevel=0)
    # level > 0, wrong data is catched
    for level in [1,2,3]:
      self.assertRaises(gfapy.ValueError,
        gfapy.line.Header,["H", "zz:B:i,1,1,A"],vlevel=level)
      self.assertRaises(gfapy.FormatError,
        gfapy.line.Header,["H", "zz:i:1A"],vlevel=level)

  def test_duplicate_tag(self):
    for version in ["gfa1","gfa2"]:
      gfapy.line.Header(["H", "zz:i:1", "VN:Z:1", "zz:i:2"],
                              version=version, vlevel=0) # nothing raised
      gfapy.Line("H\tzz:i:1\tVN:Z:0\tzz:i:2",version=version,
                                               vlevel=0) # nothing raised
      gfapy.Line("H\tzz:i:1\tVN:Z:0\tzz:i:2",version=version,
                                          vlevel=0) # nothing raised
      for level in [1,2,3]:
        self.assertRaises(gfapy.NotUniqueError, gfapy.line.Header,
          ["H", "zz:i:1", "VN:Z:0", "zz:i:2"], version=version, vlevel=level)
        self.assertRaises(gfapy.NotUniqueError, gfapy.Line,
            "H\tzz:i:1\tVN:Z:0\tzz:i:2",version=version, vlevel=level)
        self.assertRaises(gfapy.NotUniqueError, gfapy.Gfa,
            "H\tzz:i:1\tVN:Z:#{version}\tzz:i:2", version=version, vlevel=level)

  def test_validate_field(self):
    l = gfapy.line.Header(["H", "zz:i:1", "VN:Z:1.0"], version="gfa1", vlevel=0)
    l.zz = "x"
    self.assertRaises(gfapy.FormatError, l.validate_field, "zz")
    l.set_datatype("zz", "Z")
    l.validate_field("zz") # nothing raised

  def test_validate(self):
    # wrong tag value
    l = gfapy.line.Header(["H", "zz:i:1", "VN:Z:1.0"], version="gfa1", vlevel=0)
    l.zz = "x"
    self.assertRaises(gfapy.FormatError, l.validate)
    # wrong predefined tag datatype
    l = gfapy.line.Header(["H", "zz:i:1", "VN:i:1"], version="gfa1", vlevel=0)
    self.assertRaises(gfapy.TypeError, l.validate)

  # test tags for get/set tests:
  # - KC -> predefined, set
  # - RC -> predefined, not set;
  # - xx -> custom set
  # - zz -> custom not set
  # - XX -> custom, not set, upper case

  def test_get_tag_content(self):
    for version in ["gfa1","gfa2"]:
      for level in [0,1,2,3]:
        l = gfapy.Line(["S", "12","*","xx:f:1.3","KC:i:10"], vlevel=level)
        # tagnames
        self.assertEqual(sorted(["xx", "KC"]), sorted(l.tagnames))
        # test presence of tag
        assert(l.KC)
        assert(not l.RC)
        assert(not l.XX)
        assert(l.xx)
        assert(not l.zz)
        # tagname as attribute
        self.assertEqual(10, l.KC)
        self.assertEqual(None, l.RC)
        self.assertEqual(None, l.XX)
        self.assertEqual(1.3, l.xx)
        self.assertEqual(None, l.zz)
        # get(tagname)
        self.assertEqual(10, l.get("KC"))
        self.assertEqual(None, l.get("RC"))
        self.assertEqual(None, l.get("XX"))
        self.assertEqual(1.3, l.get("xx"))
        self.assertEqual(None, l.get("zz"))
        # try_get_<tagname>()
        self.assertEqual(10, l.try_get_KC())
        self.assertRaises(gfapy.NotFoundError, l.try_get_RC)
        with self.assertRaises(gfapy.NotFoundError):
          l.try_get_XX()
        self.assertEqual(1.3, l.try_get_xx())
        with self.assertRaises(gfapy.NotFoundError):
          l.try_get_zz()
        # try_get(tagname)
        self.assertEqual(10, l.try_get("KC"))
        self.assertRaises(gfapy.NotFoundError, l.try_get, "RC")
        self.assertRaises(gfapy.NotFoundError, l.try_get, "XX")
        self.assertEqual(1.3, l.try_get("xx"))
        self.assertRaises(gfapy.NotFoundError, l.try_get, "zz")
        # get_datatype(tagname)
        self.assertEqual("i", l.get_datatype("KC"))
        self.assertEqual("i", l.get_datatype("RC"))
        self.assertEqual(None, l.get_datatype("XX"))
        self.assertEqual("f", l.get_datatype("xx"))
        self.assertEqual(None, l.get_datatype("zz"))
        # field_to_s(tagname, tag=False)
        self.assertEqual("10", l.field_to_s("KC"))
        self.assertRaises(gfapy.NotFoundError, l.field_to_s, "RC")
        self.assertRaises(gfapy.NotFoundError, l.field_to_s, "XX")
        self.assertEqual("1.3", l.field_to_s("xx"))
        self.assertRaises(gfapy.NotFoundError, l.field_to_s, "zz")
        # field_to_s(tagname, tag=True)
        self.assertEqual("KC:i:10", l.field_to_s("KC", tag=True))
        self.assertEqual("xx:f:1.3", l.field_to_s("xx", tag=True))

  def test_set_tag_content(self):
    for version in ["gfa1","gfa2"]:
      for level in [0,1,2,3]:
        l = gfapy.Line(["S", "12","*","xx:f:13","KC:i:10"], vlevel=level)
        # set tag content, fieldname methods
        l.KC = 12 # nothing raised; self.assertEqual(12, l.KC)
        l.RC = 12 # nothing raised; self.assertEqual(12, l.RC)
        l.xx = 1.2 # nothing raised; self.assertEqual(1.2, l.xx)
        l.zz = 1.2 # nothing raised; self.assertEqual(1.2, l.zz)
        # set tag content, set()
        l.set("KC", 14) # nothing raised; self.assertEqual(14, l.KC)
        l.set("RC", 14) # nothing raised; self.assertEqual(14, l.RC)
        l.set("xx", 1.4) # nothing raised; self.assertEqual(1.4, l.xx)
        l.set("zz", 1.4) # nothing raised; self.assertEqual(1.4, l.zz)
        # set datatype for predefined field
        self.assertRaises(gfapy.RuntimeError, l.set_datatype, "KC","Z")
        self.assertRaises(gfapy.RuntimeError, l.set_datatype, "RC","Z")
        # set datatype for non-existing custom tag
        l.set_datatype("zz", "i") # nothing raised
        l.set_datatype("XX", "Z") # nothing raised
        # change datatype for existing custom tag
        l.xx = 1.1 # nothing raised
        l.xx = "1.1" # nothing raised
        if level == 2:
          l.xx = "1A" # nothing raised
          with self.assertRaises(gfapy.FormatError):
            str(l)
        elif level == 3:
          with self.assertRaises(gfapy.FormatError):
            l.xx = "1A"
        l.set_datatype("xx", "Z"); l.xx = "1A"  # nothing raised
        # unknown datatype
        self.assertRaises(gfapy.ArgumentError, l.set_datatype, "xx", "P")

  def test_delete_tag(self):
    for version in ["gfa1","gfa2"]:
      for level in [0,1,2,3]:
        l = gfapy.Line(["S", "12","*","xx:f:13","KC:i:10"], vlevel=level)
        # delete method
        l.delete("KC") # nothing raised
        self.assertEqual(None, l.KC)
        self.assertEqual(["xx"], l.tagnames)
        l.delete("RC") # nothing raised
        l.delete("XX") # nothing raised
        l.delete("xx") # nothing raised
        self.assertEqual([], l.tagnames)
        l.delete("zz") # nothing raised
        l = gfapy.Line(["S", "12","*","xx:f:13","KC:i:10"], vlevel=level)
        # set to None
        l.set("KC",None)  # nothing raised
        self.assertEqual(None, l.KC)
        self.assertEqual(["xx"], l.tagnames)
        l.set("RC",None)  # nothing raised
        l.set("XX",None)  # nothing raised
        l.set("xx",None)  # nothing raised
        self.assertEqual([], l.tagnames)
        l.set("zz",None)  # nothing raised

  def test_datatype_to_python_objects(self):
    l = gfapy.line.Header(["H", "a1:A:1", "z1:Z:hallo",
                                "b1:B:c,12,12", "b2:B:f,1E-2,3.0,3",
                                "h1:H:00A1",
                                "j1:J:[12,\"a\"]", "j2:J:{\"a\":1,\"b\":[2,3]}",
                                "f1:f:-1.23E-04", "i1:i:-123"])
    self.assertEqual(str, l.a1.__class__)
    self.assertEqual(str, l.z1.__class__)
    self.assertEqual(gfapy.NumericArray, l.b1.__class__)
    self.assertEqual(gfapy.NumericArray, l.b2.__class__)
    self.assertEqual(gfapy.ByteArray, l.h1.__class__)
    self.assertEqual(list, l.j1.__class__)
    self.assertEqual(dict, l.j2.__class__)
    self.assertEqual(int, l.i1.__class__)
    self.assertEqual(float, l.f1.__class__)


  def test_python_object_to_datatype(self):
    l = gfapy.line.Header(["H"])
    # String
    l.zz="1"  # nothing raised
    self.assertEqual("1", l.zz)
    self.assertEqual("Z", l.get_datatype("zz"))
    self.assertEqual("1", l.field_to_s("zz"))
    self.assertEqual("1", gfapy.Line(str(l)).zz)
    # Integer
    l.ii=1  # nothing raised
    self.assertEqual(1, l.ii)
    self.assertEqual("i", l.get_datatype("ii"))
    self.assertEqual("1", l.field_to_s("ii"))
    self.assertEqual(1, gfapy.Line(str(l)).ii)
    # Float
    l.ff=1.0  # nothing raised
    self.assertEqual(1.0, l.ff)
    self.assertEqual("f", l.get_datatype("ff"))
    self.assertEqual("1.0", l.field_to_s("ff"))
    self.assertEqual(1.0, gfapy.Line(str(l)).ff)
    # Array: all floats
    l.af=[1.0,1.0]  # nothing raised
    self.assertEqual([1.0,1.0], l.af)
    self.assertEqual("B", l.get_datatype("af"))
    self.assertEqual("f,1.0,1.0", l.field_to_s("af"))
    self.assertEqual([1.0,1.0], gfapy.Line(str(l)).af)
    # Array: all integers
    l.ai=[1,1]  # nothing raised
    self.assertEqual([1,1], l.ai)
    self.assertEqual("B", l.get_datatype("ai"))
    self.assertEqual("C,1,1", l.field_to_s("ai"))
    self.assertEqual([1,1], gfapy.Line(str(l)).ai)
    # Array: anything else
    l.aa=[1,1.0,"X"]  # nothing raised
    self.assertEqual([1,1.0,"X"], l.aa)
    self.assertEqual("J", l.get_datatype("aa"))
    self.assertEqual('[1, 1.0, "X"]', l.field_to_s("aa"))
    self.assertEqual([1,1.0,"X"], gfapy.Line(str(l)).aa)
    # Hash
    l.hh={"a":1.0, "b":1}  # nothing raised
    self.assertEqual({"a":1.0,"b":1}, l.hh)
    self.assertEqual("J", l.get_datatype("hh"))
    try:
      self.assertEqual('{"a": 1.0, "b": 1}', l.field_to_s("hh"))
    except:
      self.assertEqual('{"b": 1, "a": 1.0}', l.field_to_s("hh"))
    self.assertEqual({"a":1.0,"b":1}, gfapy.Line(str(l)).hh)
    # gfapy.ByteArray
    l.ba=gfapy.ByteArray([0,255])  # nothing raised
    self.assertEqual(gfapy.ByteArray([0,255]), l.ba)
    self.assertEqual("H", l.get_datatype("ba"))
    self.assertEqual('00FF', l.field_to_s("ba"))
    self.assertEqual(gfapy.ByteArray([0,255]), gfapy.Line(str(l)).ba)

  def test_byte_arrays(self):
    # creation:, from array, from string
    a = gfapy.ByteArray([1,2,3,4,5]) # nothing raised
    b = gfapy.ByteArray([1,2,3,4,5]) # nothing raised
    self.assertEqual(a, b)
    c = gfapy.ByteArray("12ACF4AA601C1F") # nothing raised
    self.assertEqual(gfapy.ByteArray([18, 172, 244, 170, 96, 28, 31]), c)
    # validation
    a.validate()  # nothing raised
    with self.assertRaises(gfapy.ValueError):
      gfapy.ByteArray([1,2,3,4,356])
    with self.assertRaises(gfapy.FormatError):
      gfapy.ByteArray("12ACF4AA601C1")
    with self.assertRaises(gfapy.FormatError):
      gfapy.ByteArray("")
    with self.assertRaises(gfapy.FormatError):
      gfapy.ByteArray("12ACG4AA601C1F")
    # to string
    a = gfapy.ByteArray([18, 172, 244, 170, 96, 28, 31])
    self.assertEqual("12ACF4AA601C1F", str(a))
    a = list(a)
    a[2] = 280
    with self.assertRaises(gfapy.ValueError):
      a = gfapy.ByteArray(a)

  def test_numeric_arrays(self):
    # creation:, from array, from string
    a = gfapy.NumericArray([1,2,3,4,5]) # nothing raised
    b = gfapy.NumericArray([1,2,3,4,5]) # nothing raised
    self.assertEqual(a, b)
    c = gfapy.NumericArray.from_string("i,1,2,3,4,5") # nothing raised
    self.assertEqual(gfapy.NumericArray([1, 2, 3, 4, 5]), c)
    # validation
    a.validate()  # nothing raised
    gfapy.NumericArray([1,2,3,4,356]).validate()  # nothing raised
    self.assertRaises(gfapy.ValueError,
      gfapy.NumericArray([1,2.0,3,4,356]).validate)
    self.assertRaises(gfapy.ValueError,
      gfapy.NumericArray([1.0,2.0,3,4,356]).validate)
    self.assertRaises(gfapy.ValueError,
      gfapy.NumericArray([1,"x",3,4,356]).validate)
    with self.assertRaises(gfapy.ValueError):
        a = gfapy.NumericArray.from_string("i,1,X,2")
    with self.assertRaises(gfapy.FormatError):
        a = gfapy.NumericArray.from_string("")
    with self.assertRaises(gfapy.FormatError):
        a = gfapy.NumericArray.from_string("i,1,2,")
    with self.assertRaises(gfapy.TypeError):
        a = gfapy.NumericArray.from_string("x,1,2")
    # to string
    a = gfapy.NumericArray([18, 72, 244, 70, 96, 38, 31])
    self.assertEqual("C", a.compute_subtype())
    self.assertEqual("C,18,72,244,70,96,38,31", str(a))
    a[2] = -2
    self.assertEqual("c", a.compute_subtype())
    self.assertEqual("c,18,72,-2,70,96,38,31", str(a))
    a[2] = 280
    self.assertEqual("S", a.compute_subtype())
    self.assertEqual("S,18,72,280,70,96,38,31", str(a))
    a[2] = -280
    self.assertEqual("s", a.compute_subtype())
    self.assertEqual("s,18,72,-280,70,96,38,31", str(a))
    a[2] = 280000
    self.assertEqual("I", a.compute_subtype())
    self.assertEqual("I,18,72,280000,70,96,38,31", str(a))
    a[2] = -280000
    self.assertEqual("i", a.compute_subtype())
    self.assertEqual("i,18,72,-280000,70,96,38,31", str(a))
    a = gfapy.NumericArray([float(x) for x in a])
    self.assertEqual("f", a.compute_subtype())
    self.assertEqual("f,18.0,72.0,-280000.0,70.0,96.0,38.0,31.0", str(a))
