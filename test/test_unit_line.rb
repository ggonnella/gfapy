require_relative "../lib/rgfa.rb"
require "test/unit"

TestUnit ||= Module.new

class TestUnit::Line < Test::Unit::TestCase

  def test_initialize_not_enough_positional_fields
    assert_nothing_raised do
      RGFA::Line::Segment::Factory.new(["1","*"])
    end
    assert_raise(RGFA::FormatError) do
      RGFA::Line::Segment::Factory.new(["1"])
    end
  end

  def test_initialize_too_many_positionals
    assert_raise(RGFA::FormatError) do
      RGFA::Line::Segment::Factory.new(["1","*","*"])
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
      RGFA::Line::Segment::Factory.new(["1\t1","*","*"])
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

  def test_record_type
    l = RGFA::Line::Header.new(["xx:i:13","VN:Z:HI"])
    assert_equal(:H, l.record_type)
    assert_raise(NoMethodError) { l.record_type = "S" }
  end

  def test_add_tag
    l = RGFA::Line::Header.new(["xx:i:13","VN:Z:HI"])
    assert_equal(nil, l.xy)
    l.set(:xy, "HI")
    assert_equal("HI", l.xy)
  end

  def test_unknown_record_type
    assert_raise(RGFA::VersionError) {
      "Z\txxx".to_rgfa_line(version: :gfa1)}
    assert_nothing_raised {
      "Z\txxx".to_rgfa_line(version: :gfa2)}
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

  def test_to_s
    fields = ["xx:i:13","VN:Z:HI"]
    l = RGFA::Line::Header.new(fields.clone)
    assert_equal((["H"]+fields).join("\t"),l.to_s)
  end

end
