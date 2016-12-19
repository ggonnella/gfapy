require_relative "../lib/rgfa.rb"
require "test/unit"

TestUnit ||= Module.new

class TestUnit::Header < Test::Unit::TestCase

  def test_new
    assert_nothing_raised {
      RGFA::Line::Header.new(["VN:Z:1.0", "xx:i:11"]) }
  end

  def test_string_to_rgfa_line
    assert_nothing_raised { "H\tVN:Z:1.0".to_rgfa_line }
    assert_equal(RGFA::Line::Header, "H\tVN:Z:1.0".to_rgfa_line.class)
    assert_equal(RGFA::Line::Header.new(["VN:Z:1.0", "xx:i:11"]),
      "H\tVN:Z:1.0\txx:i:11".to_rgfa_line)
    assert_raises(RGFA::FormatError) do
      "H\tH2\tVN:Z:1.0".to_rgfa_line
    end
    assert_raises(RGFA::TypeError) do
      "H\tVN:i:1.0".to_rgfa_line
    end
  end

  def test_to_s
    assert_equal("H\tVN:Z:1.0\txx:i:11",
      RGFA::Line::Header.new(["VN:Z:1.0", "xx:i:11"]).to_s)
  end

  def test_tag_reading
    assert_equal("1.0",
      RGFA::Line::Header.new(["VN:Z:1.0", "xx:i:11"]).VN)
  end

  def test_tag_writing
    assert_nothing_raised{
      RGFA::Line::Header.new(["VN:Z:1.0", "xx:i:11"]).VN = "2.0"}
  end

  def test_connection
    assert(!RGFA::Line::Header.new([]).connected?)
    assert(RGFA.new.header.connected?)
    assert_raise(RGFA::RuntimeError) {
      RGFA::Line::Header.new([]).connect(RGFA.new) }
  end

  def test_to_gfa1a
    line = "H\tVN:Z:1.0\txx:i:1".to_rgfa_line
    assert_equal(["H","VN:Z:1.0", "xx:i:1"], line.to_gfa1_a)
    assert_equal(["H","VN:Z:2.0", "xx:i:1"], line.to_gfa2_a)
  end

  def test_to_gfa2_a
    line = "H\tVN:Z:2.0\txx:i:1".to_rgfa_line
    assert_equal(["H","VN:Z:1.0", "xx:i:1"], line.to_gfa1_a)
    assert_equal(["H","VN:Z:2.0", "xx:i:1"], line.to_gfa2_a)
  end

  def test_add
    line = "H\tVN:Z:2.0\txx:i:1".to_rgfa_line
    line.add(:yy, "test")
    assert_equal("test", line.yy)
    line.add(:yy, "test")
    assert_equal(["test","test"], line.yy)
    line.add(:yy, "test")
    assert_equal(["test","test","test"], line.yy)
    line.add(:VN, "2.0")
    assert_equal("2.0", line.VN)
    assert_raise(RGFA::InconsistencyError) {
      line.add(:VN, "1.0") }
    line.add(:TS, "120")
    assert_equal(120, line.TS)
    assert_nothing_raised {
      line.add(:TS, 120) }
    assert_nothing_raised {
      line.add(:TS, "120") }
    assert_raise(RGFA::InconsistencyError) {
      line.add(:TS, 130) }
    assert_raise(RGFA::InconsistencyError) {
      line.add(:TS, "140") }
  end

  def test_field_to_s
    line = "H\tVN:Z:1.0\txx:i:1".to_rgfa_line
    line.add(:xx, 2)
    assert_equal("1.0", line.field_to_s(:VN))
    assert_equal("1\t2", line.field_to_s(:xx))
    assert_equal("VN:Z:1.0", line.field_to_s(:VN, tag: true))
    assert_equal("xx:i:1\txx:i:2", line.field_to_s(:xx, tag: true))
  end

  def test_n_duptags
    line = "H\tVN:Z:1.0\txx:i:1".to_rgfa_line
    assert_equal(0, line.n_duptags)
    line.add(:xx, 2)
    assert_equal(1, line.n_duptags)
    line.add(:xx, 2)
    assert_equal(1, line.n_duptags)
    line.add(:zz, 2)
    assert_equal(1, line.n_duptags)
    line.add(:zz, 2)
    assert_equal(2, line.n_duptags)
  end

  def test_split
    line = "H\tVN:Z:1.0\txx:i:1".to_rgfa_line
    line.add(:xx, 2)
    assert_equal(3, line.split.size)
    line.split.each {|s| assert_equal(RGFA::Line::Header, s.class) }
    assert_equal(["H\tVN:Z:1.0", "H\txx:i:1", "H\txx:i:2"],
                 line.split.map(&:to_s))
  end

  def test_merge
    line1 = "H\tVN:Z:1.0\txx:i:1".to_rgfa_line
    line2 = "H\txx:i:2\tyy:f:1.0".to_rgfa_line
    line1.merge(line2)
    assert_equal("1.0", line1.VN)
    assert_equal([1,2], line1.xx)
    assert_equal(1.0, line1.yy)
  end

end
