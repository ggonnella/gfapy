require_relative "../lib/rgfa.rb"
require "test/unit"
TestAPI ||= Module.new

class TestAPI::Tags < Test::Unit::TestCase

  def test_predefined_tags
    # correct type:
    assert_nothing_raised do
      RGFA::Line::Header.new(["VN:Z:1"], vlevel: 3)
    end
    # custom tags with the same letters as predefined tags but lower case
    assert_nothing_raised do
      RGFA::Line::Header.new(["vn:i:1"], vlevel: 3)
    end
    # wrong type
    assert_nothing_raised do
      RGFA::Line::Header.new(["VN:i:1"], vlevel: 0)
    end
    [1,2,3].each do |level|
      assert_raise(RGFA::TypeError) do
        RGFA::Line::Header.new(["VN:i:1"], vlevel: level)
      end
    end
  end

  def test_custom_tags
    [:gfa1, :gfa2].each do |version|
      # upper case
      assert_nothing_raised do
        RGFA::Line::Header.new(["ZZ:Z:1"], version: version, vlevel: 0)
      end
      assert_nothing_raised do
        "H\tZZ:Z:1".to_rgfa_line(version: version, vlevel: 0)
      end
      assert_nothing_raised do
        "H\tZZ:Z:1".to_rgfa(version: version, vlevel: 0)
      end
      [1,2,3].each do |level|
        assert_raise(RGFA::FormatError) do
          RGFA::Line::Header.new(["ZZ:Z:1"], version: version, vlevel: level)
        end
        assert_raise(RGFA::FormatError) do
          "H\tZZ:Z:1".to_rgfa_line(version: version, vlevel: level)
        end
        assert_raise(RGFA::FormatError) do
          "H\tZZ:Z:1".to_rgfa(version: version, vlevel: level)
        end
      end
      # lower case
      [0,1,2,3].each do |level|
        assert_nothing_raised do
          RGFA::Line::Header.new(["zz:Z:1"], version: version, vlevel: 0)
          "H\tzz:Z:1".to_rgfa_line(version: version, vlevel: 0)
          "H\tzz:Z:1".to_rgfa(version: version, vlevel: 0)
        end
      end
    end
  end

  def test_wrong_tag_format
    assert_raise(RGFA::FormatError) do
      RGFA::Line::Header.new(["VN i:1"])
    end
    assert_raise(RGFA::FormatError) do
      RGFA::Line::Header.new(["vna:i:1"])
    end
    assert_raise(RGFA::FormatError) do
      RGFA::Line::Header.new(["VN:ZZ:1"])
    end
    # the content can include :, so four : are e.g. not an error
    assert_equal("1:1:1", RGFA::Line::Header.new(["VN:Z:1:1:1"]).VN)
  end

  def test_wrong_tag_data
    # validation level 0
    # - some wrong data passes through
    assert_nothing_raised {
      RGFA::Line::Header.new(["zz:B:i,1,1,A"], vlevel: 0) }
    assert_nothing_raised {
      RGFA::Line::Header.new(["zz:Z:i,\t1,1,A"], vlevel: 0) }
    # - some errors are catched
    assert_raise(RGFA::FormatError) do
      RGFA::Line::Header.new(["zz:i:1A"], vlevel: 0)
    end
    # level > 0, wrong data is catched
    [1,2,3].each do |level|
      assert_raise(RGFA::ValueError) do
        RGFA::Line::Header.new(["zz:B:i,1,1,A"], vlevel: level)
      end
      assert_raise(RGFA::FormatError) do
        RGFA::Line::Header.new(["zz:i:1A"], vlevel: level)
      end
    end
  end

  def test_duplicate_tag
    [:gfa1, :gfa2].each do |version|
      assert_nothing_raised do
        RGFA::Line::Header.new(["zz:i:1", "VN:Z:1", "zz:i:2"],
                                version: version, vlevel: 0)
      end
      assert_nothing_raised do
        "H\tzz:i:1\tVN:Z:0\tzz:i:2".to_rgfa_line(version: version,
                                                 vlevel: 0)
      end
      assert_nothing_raised do
        "H\tzz:i:1\tVN:Z:0\tzz:i:2".to_rgfa(version: version,
                                            vlevel: 0)
      end
      [1,2,3].each do |level|
        assert_raise(RGFA::NotUniqueError) do
          RGFA::Line::Header.new(["zz:i:1", "VN:Z:0", "zz:i:2"],
                                 version: version,
                                 vlevel: level)
        end
        assert_raise(RGFA::NotUniqueError) do
          "H\tzz:i:1\tVN:Z:0\tzz:i:2".to_rgfa_line(version: version,
                                                   vlevel: level)
        end
        assert_raise(RGFA::NotUniqueError) do
          "H\tzz:i:1\tVN:Z:#{version}\tzz:i:2".to_rgfa(version: version,
                                                       vlevel: level)
        end
      end
    end
  end

  # test tags for get/set tests:
  # - KC -> predefined, set
  # - RC -> predefined, not set;
  # - XX -> custom, invalid (upper case)
  # - xx -> custom set
  # - zz -> custom not set

  def test_get_tag_content
    [:gfa1, :gfa2].each do |version|
      [0,1,2,3].each do |level|
      l = RGFA::Line::Segment::Factory.new(["12","*","xx:f:1.3","KC:i:10"],
                                           vlevel: level)
        # tagnames
        assert_equal([:xx, :KC], l.tagnames)
        # test presence of tag
        assert(l.KC)
        assert(!l.RC)
        assert_raise(NoMethodError) { l.XX }
        assert(l.xx)
        assert(!l.zz)
        # get tag content, fieldname methods
        assert_equal(10, l.KC)
        assert_equal(nil, l.RC)
        assert_raise(NoMethodError) { l.XX }
        assert_equal(1.3, l.xx)
        assert_equal(nil, l.zz)
        # get tag content, get()
        assert_equal(10, l.get(:KC))
        assert_equal(nil, l.get(:RC))
        assert_equal(nil, l.get(:XX))
        assert_equal(1.3, l.get(:xx))
        assert_equal(nil, l.get(:zz))
        # banged version, fieldname methods
        assert_equal(10, l.KC!)
        assert_raise(RGFA::NotFoundError) { l.RC! }
        assert_raise(NoMethodError) { l.XX! }
        assert_equal(1.3, l.xx!)
        assert_raise(RGFA::NotFoundError) { l.zz! }
        # banged version, get()
        assert_equal(10, l.get!(:KC))
        assert_raise(RGFA::NotFoundError) { l.get!(:RC) }
        assert_raise(RGFA::NotFoundError) { l.get!(:XX) }
        assert_equal(1.3, l.get!(:xx))
        assert_raise(RGFA::NotFoundError) { l.get!(:zz) }
        # get tag datatype
        assert_equal(:i, l.get_datatype(:KC))
        assert_equal(:i, l.get_datatype(:RC))
        assert_equal(nil, l.get_datatype(:XX))
        assert_equal(:f, l.get_datatype(:xx))
        assert_equal(nil, l.get_datatype(:zz))
        # as string: content only
        assert_equal("10", l.field_to_s(:KC))
        assert_raise(RGFA::NotFoundError) { l.field_to_s(:RC) }
        assert_raise(RGFA::NotFoundError) { l.field_to_s(:XX) }
        assert_equal("1.3", l.field_to_s(:xx))
        assert_raise(RGFA::NotFoundError) { l.field_to_s(:zz) }
        # as string: complete
        assert_equal("KC:i:10", l.field_to_s(:KC, tag: true))
        assert_equal("xx:f:1.3", l.field_to_s(:xx, tag: true))
        # respond_to? normal version
        assert(l.respond_to?(:KC))
        assert(l.respond_to?(:RC))
        assert(!l.respond_to?(:XX))
        assert(l.respond_to?(:xx))
        assert(l.respond_to?(:zz))
        # respond_to? banged version
        assert(l.respond_to?(:KC!))
        assert(l.respond_to?(:RC!))
        assert(!l.respond_to?(:XX!))
        assert(l.respond_to?(:xx!))
        assert(l.respond_to?(:zz!))
      end
    end
  end

  def test_set_tag_content
    [:gfa1, :gfa2].each do |version|
      [0,3,4,5].each do |level|
        l = RGFA::Line::Segment::Factory.new(["12","*","xx:f:13","KC:i:10"],
                                             vlevel: level)
        # set tag content, fieldname methods
        assert_nothing_raised { l.KC = 12 }; assert_equal(12, l.KC)
        assert_nothing_raised { l.RC = 12 }; assert_equal(12, l.RC)
        assert_nothing_raised { l.xx = 1.2 }; assert_equal(1.2, l.xx)
        assert_nothing_raised { l.zz = 1.2 }; assert_equal(1.2, l.zz)
        # set tag content, set()
        assert_nothing_raised { l.set(:KC, 14) }; assert_equal(14, l.KC)
        assert_nothing_raised { l.set(:RC, 14) }; assert_equal(14, l.RC)
        assert_nothing_raised { l.set(:xx, 1.4) }; assert_equal(1.4, l.xx)
        assert_nothing_raised { l.set(:zz, 1.4) }; assert_equal(1.4, l.zz)
        # respond to?
        assert(l.respond_to?(:KC=))
        assert(l.respond_to?(:RC=))
        assert(!l.respond_to?(:XX=))
        assert(l.respond_to?(:xx=))
        assert(l.respond_to?(:zz=))
        # set datatype for predefined field
        assert_raise(RGFA::RuntimeError) { l.set_datatype(:KC, :Z) }
        assert_raise(RGFA::RuntimeError) { l.set_datatype(:RC, :Z) }
        # set datatype for non-existing custom tag
        assert_nothing_raised { l.set_datatype(:zz, :i) }
        if level == 0
          assert_nothing_raised { l.set_datatype(:XX, :Z) }
        elsif level >= 1
          assert_raise(RGFA::FormatError) { l.set_datatype(:XX, :Z) }
        end
        # change datatype for existing custom tag
        assert_nothing_raised { l.xx = 1.1 }
        assert_nothing_raised { l.xx = "1.1" }
        if level == 2
          assert_nothing_raised { l.xx = "1A" }
          assert_raise(RGFA::FormatError) { l.to_s }
        elsif level == 3
          assert_raise(RGFA::FormatError) { l.xx = "1A" }
        end
        assert_nothing_raised { l.set_datatype(:xx, :Z); l.xx = "1A" }
        # unknown datatype
        assert_raise(RGFA::ArgumentError) { l.set_datatype(:xx, :P) }
      end
    end
  end

  def test_delete_tag
    [:gfa1, :gfa2].each do |version|
      [0,3,4,5].each do |level|
        l = RGFA::Line::Segment::Factory.new(["12","*","xx:f:13","KC:i:10"],
                                             vlevel: level)
        # delete method
        assert_nothing_raised { l.delete(:KC) }
        assert_equal(nil, l.KC)
        assert_equal([:xx], l.tagnames)
        assert_nothing_raised { l.delete(:RC) }
        assert_nothing_raised { l.delete(:XX) }
        assert_nothing_raised { l.delete(:xx) }
        assert_equal([], l.tagnames)
        assert_nothing_raised { l.delete(:zz) }
        l = RGFA::Line::Segment::Factory.new(["12","*","xx:f:13","KC:i:10"],
                                             vlevel: level)
        # set to nil
        assert_nothing_raised { l.set(:KC,nil) }
        assert_equal(nil, l.KC)
        assert_equal([:xx], l.tagnames)
        assert_nothing_raised { l.set(:RC,nil) }
        if level == 0
          assert_nothing_raised { l.set(:XX,nil) }
        else
          assert_raises(RGFA::FormatError) { l.set(:XX,nil) }
        end
        assert_nothing_raised { l.set(:xx,nil) }
        assert_equal([], l.tagnames)
        assert_nothing_raised { l.set(:zz,nil) }
      end
    end
  end

  def test_datatype_to_ruby_objects
    l = RGFA::Line::Header.new(["a1:A:1", "z1:Z:hallo",
                                "b1:B:c,12,12", "b2:B:f,1E-2,3.0,3",
                                "h1:H:00A1",
                                "j1:J:[12,\"a\"]", "j2:J:{\"a\":1,\"b\":[2,3]}",
                                "f1:f:-1.23E-04", "i1:i:-123"])
    assert_equal(String, l.a1.class)
    assert_equal(String, l.z1.class)
    assert_equal(RGFA::NumericArray, l.b1.class)
    assert_equal(RGFA::NumericArray, l.b2.class)
    assert_equal(RGFA::ByteArray, l.h1.class)
    assert_equal(Array, l.j1.class)
    assert_equal(Hash, l.j2.class)
    assert_equal(Fixnum, l.i1.class)
    assert_equal(Float, l.f1.class)
  end

  def test_ruby_object_to_datatype
    l = RGFA::Line::Header.new([])
    # String
    assert_nothing_raised { l.zz="1" }
    assert_equal("1", l.zz)
    assert_equal(:"Z", l.get_datatype(:zz))
    assert_equal("1", l.field_to_s(:zz))
    assert_equal("1", l.to_s.to_rgfa_line.zz)
    # Integer
    assert_nothing_raised { l.ii=1 }
    assert_equal(1, l.ii)
    assert_equal(:"i", l.get_datatype(:ii))
    assert_equal("1", l.field_to_s(:ii))
    assert_equal(1, l.to_s.to_rgfa_line.ii)
    # Float
    assert_nothing_raised { l.ff=1.0 }
    assert_equal(1.0, l.ff)
    assert_equal(:"f", l.get_datatype(:ff))
    assert_equal("1.0", l.field_to_s(:ff))
    assert_equal(1.0, l.to_s.to_rgfa_line.ff)
    # Array: all floats
    assert_nothing_raised { l.af=[1.0,1.0] }
    assert_equal([1.0,1.0], l.af)
    assert_equal(:"B", l.get_datatype(:af))
    assert_equal("f,1.0,1.0", l.field_to_s(:af))
    assert_equal([1.0,1.0].to_byte_array, l.to_s.to_rgfa_line.af)
    # Array: all integers
    assert_nothing_raised { l.ai=[1,1] }
    assert_equal([1,1], l.ai)
    assert_equal(:"B", l.get_datatype(:ai))
    assert_equal("C,1,1", l.field_to_s(:ai))
    assert_equal([1,1].to_byte_array, l.to_s.to_rgfa_line.ai)
    # Array: anything else
    assert_nothing_raised { l.aa=[1,1.0,:X] }
    assert_equal([1,1.0,:X], l.aa)
    assert_equal(:"J", l.get_datatype(:aa))
    assert_equal('[1,1.0,"X"]', l.field_to_s(:aa))
    assert_equal([1,1.0,"X"], l.to_s.to_rgfa_line.aa)
    # Hash
    assert_nothing_raised { l.hh={:a => 1.0, :b => 1} }
    assert_equal({:a=>1.0,:b=>1}, l.hh)
    assert_equal(:"J", l.get_datatype(:hh))
    assert_equal('{"a":1.0,"b":1}', l.field_to_s(:hh))
    assert_equal({"a"=>1.0,"b"=>1}, l.to_s.to_rgfa_line.hh)
    # RGFA::ByteArray
    assert_nothing_raised { l.ba=[0,255].to_byte_array }
    assert_equal([0,255].to_byte_array, l.ba)
    assert_equal(:H, l.get_datatype(:ba))
    assert_equal('00FF', l.field_to_s(:ba))
    assert_equal([0,255].to_byte_array, l.to_s.to_rgfa_line.ba)
  end

  def test_byte_arrays
    # creation: new, from array, from string
    a,b,c=nil
    assert_nothing_raised { a = RGFA::ByteArray.new([1,2,3,4,5]) }
    assert_nothing_raised { b = [1,2,3,4,5].to_byte_array }
    assert_equal(a, b)
    assert_nothing_raised { c = "12ACF4AA601C1F".to_byte_array }
    assert_equal([18, 172, 244, 170, 96, 28, 31].to_byte_array, c)
    # validation
    assert_nothing_raised { a.validate }
    assert_nothing_raised { a = RGFA::ByteArray.new([1,2,3,4,356]) }
    assert_raises(RGFA::ValueError) { a.validate }
    assert_raises(RGFA::FormatError) { a = "12ACF4AA601C1".to_byte_array }
    assert_raises(RGFA::FormatError) { a = "".to_byte_array }
    assert_raises(RGFA::FormatError) { a = "12ACG4AA601C1F".to_byte_array }
    # to string
    a = [18, 172, 244, 170, 96, 28, 31].to_byte_array
    assert_equal("12ACF4AA601C1F", a.to_s)
    a[2] = 280
    assert_raises(RGFA::ValueError) { a.to_s }
  end

  def test_numeric_arrays
    # creation: new, from array, from string
    a,b,c=nil
    assert_nothing_raised { a = RGFA::NumericArray.new([1,2,3,4,5]) }
    assert_nothing_raised { b = [1,2,3,4,5].to_numeric_array }
    assert_equal(a, b)
    assert_nothing_raised { c = "i,1,2,3,4,5".to_numeric_array }
    assert_equal([1, 2, 3, 4, 5].to_numeric_array, c)
    # validation
    assert_nothing_raised { a.validate }
    assert_nothing_raised { RGFA::NumericArray.new([1,2,3,4,356]).validate }
    assert_raises(RGFA::ValueError) {
      RGFA::NumericArray.new([1,2.0,3,4,356]).validate }
    assert_raises(RGFA::ValueError) {
      RGFA::NumericArray.new([1.0,2.0,3,4,356]).validate }
    assert_raises(RGFA::ValueError) {
      RGFA::NumericArray.new([1,:x,3,4,356]).validate }
    assert_raises(RGFA::ValueError) { a = "i,1,X,2".to_numeric_array }
    assert_raises(RGFA::FormatError) { a = "".to_numeric_array }
    assert_raises(RGFA::FormatError) { a = "i,1,2,".to_numeric_array }
    assert_raises(RGFA::TypeError) { a = "x,1,2".to_numeric_array }
    # to string
    a = [18, 72, 244, 70, 96, 38, 31].to_numeric_array
    assert_equal("C", a.compute_subtype)
    assert_equal("C,18,72,244,70,96,38,31", a.to_s)
    a[2] = -2
    assert_equal("c", a.compute_subtype)
    assert_equal("c,18,72,-2,70,96,38,31", a.to_s)
    a[2] = 280
    assert_equal("S", a.compute_subtype)
    assert_equal("S,18,72,280,70,96,38,31", a.to_s)
    a[2] = -280
    assert_equal("s", a.compute_subtype)
    assert_equal("s,18,72,-280,70,96,38,31", a.to_s)
    a[2] = 280000
    assert_equal("I", a.compute_subtype)
    assert_equal("I,18,72,280000,70,96,38,31", a.to_s)
    a[2] = -280000
    assert_equal("i", a.compute_subtype)
    assert_equal("i,18,72,-280000,70,96,38,31", a.to_s)
    a.map! {|x|x.to_f}
    assert_equal("f", a.compute_subtype)
    assert_equal("f,18.0,72.0,-280000.0,70.0,96.0,38.0,31.0", a.to_s)
  end

end
