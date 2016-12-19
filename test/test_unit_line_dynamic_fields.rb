require_relative "../lib/rgfa.rb"
require "test/unit"

TestUnit ||= Module.new

class TestUnit::DynamicFields < Test::Unit::TestCase

  def test_respond_to
    l = RGFA::Line::Edge::Link.new(["1","+","2","-","*","zz:Z:yes","KC:i:100"])
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

  def test_field_getters_positional_fields
    l = RGFA::Line::Segment::Factory.new(["12","*","xx:i:13","KC:i:10"])
    assert_equal(:"12", l.name)
    assert_raise(NoMethodError) { l.zzz }
  end

  def test_field_getters_existing_tags
    l = RGFA::Line::Segment::Factory.new(["12","*","xx:i:13","KC:i:10"])
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
    l = RGFA::Line::Segment::Factory.new(["12","*","xx:i:13","KC:i:1200"])
    assert_raise(RGFA::FormatError) { l.name = "A\t1";
                                                   l.validate_field(:name) }
    l.name = "14"
    assert_equal(:"14", l.name)
  end

  def test_field_setters_existing_tags
    l = RGFA::Line::Header.new(["xx:i:13","VN:Z:HI"], vlevel: 3)
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
    assert_nothing_raised { l.zi=1 }
    assert_equal(1, l.zi)
    assert_nothing_raised { l.zf=1.0 }
    assert_equal(1.0, l.zf)
    assert_nothing_raised { l.bf=[1.0,1.0] }
    assert_equal([1.0,1.0], l.bf)
    assert_nothing_raised { l.bi=[1.0,1.0] }
    assert_equal([1,1], l.bi)
    assert_nothing_raised { l.ba=[1.0,1] }
    assert_equal([1.0,1], l.ba)
    assert_nothing_raised { l.bh={:a => 1.0, :b => 1} }
    assert_equal({"a"=>1.0,"b"=>1}, l.to_s.to_rgfa_line.bh)
    assert_raise(NoMethodError) { l.zzz="1" }
  end

end
