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

  def test_rgfa_header_line_connect
    g = RGFA.new
    line = "H\txx:i:1".to_rgfa_line
    assert_raise(RGFA::RuntimeError) { line.connect(g) }
    assert_nothing_raised { g.add_line(line) }
  end

  def test_header_version_editing
    standalone = "H\txx:i:1\tVN:Z:1.0".to_rgfa_line
    assert_nothing_raised {standalone.VN = "2.0"}
    g = RGFA.new
    g << "H\txx:i:1\tVN:Z:1.0"
    assert_nothing_raised { g.header.xx = 2}
    assert_raise(RGFA::RuntimeError) {
      g.header.VN = "2.0" }
  end

  def test_error_inconsistent_definitions
    g = RGFA.new
    g << "H\txx:i:1"
    assert_nothing_raised {g << "H\txx:i:2" }
    g << "H\tTS:i:120"
    assert_nothing_raised {g << "H\tTS:i:120" }
    assert_raise(RGFA::InconsistencyError) { g << "H\tTS:i:122" }
  end

  def test_rgfa_multiple_def_tags
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
    assert_equal(["H\txx:i:1","H\txx:i:4"], g.headers.map(&:to_s))
    g.header.add(:xx, 12)
    g.header.add(:yy, 13)
    assert_equal([1,4,12], g.header.xx)
    assert_equal(13, g.header.yy)
  end

  def test_rgfa_single_def_tags
    g = RGFA.new
    g << "H\txx:i:1".to_rgfa_line
    assert_equal([:xx], g.header.tagnames)
    assert_equal(1, g.header.xx)
    g.header.set(:xx, 12)
    assert_equal(12, g.header.xx)
    g.header.delete(:xx)
    assert_equal(nil, g.header.xx)
  end

end
