require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFALine < Test::Unit::TestCase

  def test_initialize_not_enough_positional_fields
    assert_nothing_raised do
      RGFA::Line::Segment.new(["1","*"])
    end
    assert_raise(RGFA::FormatError) do
      RGFA::Line::Segment.new(["1"])
    end
  end

  def test_initialize_too_many_positionals
    assert_raise(RGFA::FormatError) do
      RGFA::Line::Segment.new(["1","*","*"])
    end
  end

  def test_initialize_predefined_tag_wrong_type
    assert_nothing_raised do
      RGFA::Line::Header.new(["VN:Z:1"])
    end
    assert_raise(RGFA::TypeError) do
      RGFA::Line::Header.new(["VN:i:1"])
    end
  end

  def test_initialize_wrong_tag_format
    assert_raise(RGFA::FormatError) do
      RGFA::Line::Header.new(["VN i:1"])
    end
  end

  def test_initialize_positional_field_type_error
    assert_raise(RGFA::FormatError) do
      RGFA::Line::Segment.new(["1\t1","*","*"])
    end
  end

  def test_initialize_tag_type_error
    assert_raise(RGFA::FormatError) do
      RGFA::Line::Header.new(["zz:i:1A"])
    end
  end

  def test_initialize_duplicate_tag
    assert_raise(RGFA::NotUniqueError) do
      RGFA::Line::Header.new(["zz:i:1","zz:i:2"])
    end
    assert_raise(RGFA::NotUniqueError) do
      RGFA::Line::Header.new(["zz:i:1", "VN:Z:1", "zz:i:2"])
    end
  end

  def test_initialize_custom_tag
    assert_raise(RGFA::FormatError) do
      RGFA::Line::Header.new(["ZZ:Z:1"])
    end
  end

  def test_clone
    l = "H\tVN:Z:1.0".to_rgfa_line
    l1 = l
    l2 = l.clone
    assert_equal(RGFA::Line::Header, l.class)
    assert_equal(RGFA::Line::Header, l2.class)
    l2.VN="2.0"
    assert_equal("2.0", l2.VN)
    assert_equal("1.0", l.VN)
    l1.VN="2.0"
    assert_equal("2.0", l.VN)
  end

  def test_respond_to
    l = RGFA::Line::Link.new(["1","+","2","-","*","zz:Z:yes","KC:i:100"])
    # record_type
    assert(l.respond_to?(:record_type))
    # reqfields
    assert(l.respond_to?(:from))
    assert(l.respond_to?(:from=))
    # predefined tags
    assert(l.respond_to?(:KC))
    assert(l.respond_to?(:KC!))
    assert(l.respond_to?(:KC=))
    # custom tags
    assert(l.respond_to?(:zz))
    assert(l.respond_to?(:zz!))
    assert(l.respond_to?(:zz=))
    # not-yet-existing tags
    assert(l.respond_to?(:aa))
    assert(l.respond_to?(:aa!))
    assert(l.respond_to?(:aa=))
  end

  def test_record_type
    l = RGFA::Line::Header.new(["xx:i:13","VN:Z:HI"])
    assert_equal(:H, l.record_type)
    assert_raise(NoMethodError) { l.record_type = "S" }
  end

  def test_field_getters_positional_fields
    l = RGFA::Line::Segment.new(["12","*","xx:i:13","KC:i:10"])
    assert_equal(:"12", l.name)
    assert_raise(NoMethodError) { l.zzz }
  end

  def test_field_getters_existing_tags
    l = RGFA::Line::Segment.new(["12","*","xx:i:13","KC:i:10"])
    assert_equal(:xx, l.tagnames[0])
    assert_equal("13", l.field_to_s(:xx))
    assert_equal(13, l.xx)
    assert_equal(13, l.xx!)
    assert_equal("10", l.field_to_s(:KC))
    assert_equal(10, l.KC)
    assert_equal(10, l.KC!)
  end

  def test_field_getters_not_existing_tags
    l = RGFA::Line::Header.new(["xx:i:13","VN:Z:HI"])
    assert_equal(nil, l.zz)
    assert_raise(RGFA::NotFoundError) { l.zz! }
  end

  def test_field_setters_positional_fields
    l = RGFA::Line::Segment.new(["12","*","xx:i:13","KC:i:1200"])
    assert_raise(RGFA::FormatError) { l.name = "A\t1";
                                                   l.validate_field!(:name) }
    l.name = "14"
    assert_equal(:"14", l.name)
  end

  def test_field_setters_existing_tags
    l = RGFA::Line::Header.new(["xx:i:13","VN:Z:HI"], validate: 5)
    assert_equal(13, l.xx)
    l.xx = 15
    assert_equal(15, l.xx)
    assert_raise(RGFA::FormatError) { l.xx = "1A" }
    assert_nothing_raised { l.set_datatype(:xx, :Z); l.xx = "1A" }
    assert_equal("HI", l.VN)
    l.VN = "HO"
    assert_equal("HO", l.VN)
  end

  def test_field_setters_not_existing_tags
    l = RGFA::Line::Header.new(["xx:i:13","VN:Z:HI"])
    assert_nothing_raised { l.zz="1" }
    assert_equal("1", l.zz)
    assert_equal(:"Z", l.zz.default_gfa_tag_datatype)
    assert_nothing_raised { l.zi=1 }
    assert_equal(1, l.zi)
    assert_equal(:"i", l.zi.default_gfa_tag_datatype)
    assert_nothing_raised { l.zf=1.0 }
    assert_equal(1.0, l.zf)
    assert_equal(:"f", l.zf.default_gfa_tag_datatype)
    assert_nothing_raised { l.bf=[1.0,1.0] }
    assert_equal([1.0,1.0], l.bf)
    assert_equal(:"B", l.bf.default_gfa_tag_datatype)
    assert_nothing_raised { l.bi=[1.0,1.0] }
    assert_equal([1,1], l.bi)
    assert_equal(:"B", l.bi.default_gfa_tag_datatype)
    assert_nothing_raised { l.ba=[1.0,1] }
    assert_equal([1.0,1], l.ba)
    assert_equal(:"J", l.ba.default_gfa_tag_datatype)
    assert_nothing_raised { l.bh={:a => 1.0, :b => 1} }
    assert_equal({"a"=>1.0,"b"=>1}, l.to_s.to_rgfa_line.bh)
    assert_equal(:"J", l.bh.default_gfa_tag_datatype)
    assert_raise(NoMethodError) { l.zzz="1" }
  end

  def test_add_tag
    l = RGFA::Line::Header.new(["xx:i:13","VN:Z:HI"])
    assert_equal(nil, l.xy)
    l.set(:xy, "HI")
    assert_equal("HI", l.xy)
  end

  def test_to_s
    fields = ["xx:i:13","VN:Z:HI"]
    l = RGFA::Line::Header.new(fields.clone)
    assert_equal((["H"]+fields).join("\t"),l.to_s)
  end

  def test_unknown_record_type
    assert_raise(RGFA::TypeError) {
      "Z\txxx".to_rgfa_line(version: :"1.0")}
    assert_nothing_raised {
      "Z\txxx".to_rgfa_line(version: :"2.0")}
    assert_nothing_raised {
      "Z\txxx".to_rgfa_line}
  end

  def test_to_rgfa_line
    str = "H\tVN:Z:1.0"
    l = str.to_rgfa_line
    assert_equal(RGFA::Line::Header, l.class)
    assert_equal(RGFA::Line::Header, l.to_rgfa_line.class)
    assert_equal(str, l.to_rgfa_line.to_s)
    assert_equal(l, l.to_rgfa_line)
  end

  def test_field_alias
    s = "S\tA\t*".to_rgfa_line
    assert_equal(:A, s.name)
    assert_equal(:A, s.sid)
    assert_equal(:A, s.get(:name))
    assert_equal(:A, s.get(:sid))
    s.set(:name, :B)
    assert_equal(:B, s.get(:sid))
    s.set(:sid, :C)
    assert_equal(:C, s.name)
  end

end
