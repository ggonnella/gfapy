require_relative "../lib/rgfa.rb"
require "test/unit"
TestAPI ||= Module.new

class TestAPI::Header < Test::Unit::TestCase

  def test_rgfa_header
    g = RGFA.new
    assert_equal(RGFA::Line::Header, g.header.class)
    assert_equal([], g.header.tagnames)
    g << "H\txx:i:1".to_rgfa_line
    assert_equal([:xx], g.header.tagnames)
  end

  def test_rgfa_duptags_header
    g = RGFA.new
    4.times do |i|
      g << "H\txx:i:#{i}".to_rgfa_line
    end
    assert_equal([:xx], g.header.tagnames)
    assert_equal([0,1,2,3], g.header.xx)
    assert_equal([0,1,2,3], g.header.get(:xx))
    assert_equal(:i, g.header.get_datatype(:xx))
    assert_nothing_raised { g.header.validate_field(:xx) }
    [0,2,3].each {|i| g.header.xx.delete(i)}
    g.header.xx = (g.header.xx += [4])
    assert_raise(RGFA::TypeError) { g.header.validate_field(:xx) }
    g.header.xx = g.header.xx.to_rgfa_field_array(:i)
    assert_nothing_raised { g.header.validate_field(:xx) }
    assert_equal([1,4], g.header.get(:xx))
    assert_equal("1\t4", g.header.field_to_s(:xx))
    assert_equal("xx:i:1\txx:i:4", g.header.field_to_s(:xx, tag: true))
    g.header.add(:xx, 12)
    g.header.add(:yy, 13)
    assert_equal([1,4,12], g.header.xx)
    assert_equal(13, g.header.yy)
  end

  def test_rgfa_unitags_header
    g = RGFA.new
    g << "H\txx:i:1".to_rgfa_line
    assert_equal([:xx], g.header.tagnames)
    assert_equal(1, g.header.xx)
    g.header.set(:xx, 12)
    assert_equal(12, g.header.xx)
    g.header.delete(:xx)
    assert_equal(nil, g.header.xx)
  end

  def test_header_from_string
    assert_nothing_raised { "H\tVN:Z:1.0".to_rgfa_line }
    assert_equal(RGFA::Line::Header, "H\tVN:Z:1.0".to_rgfa_line.class)
    assert_raises(RGFA::FormatError) do
      "H\tH2\tVN:Z:1.0".to_rgfa_line
    end
    assert_raises(RGFA::TypeError) do
      "H\tVN:i:1.0".to_rgfa_line
    end
  end

end
