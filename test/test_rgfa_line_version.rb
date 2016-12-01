require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFALineVersion < Test::Unit::TestCase

  def test_header
    assert_equal(:generic, "H\tVN:Z:1.0".to_rgfa_line.version)
    assert_equal(:gfa1, "H\tVN:Z:1.0".to_rgfa_line(version: :gfa1).version)
    assert_equal(:gfa2, "H\tVN:Z:1.0".to_rgfa_line(version: :gfa2).version)
  end

  def test_comment
    assert_equal(:generic, "# VN:Z:1.0".to_rgfa_line.version)
    assert_equal(:gfa1, "# VN:Z:1.0".to_rgfa_line(version: :gfa1).version)
    assert_equal(:gfa2, "# VN:Z:1.0".to_rgfa_line(version: :gfa2).version)
  end

  def test_segment
    assert_equal(:gfa1, "S\tA\tNNNN".to_rgfa_line.version)
    assert_equal(:gfa2, "S\tA\t1\tNNNN".to_rgfa_line.version)
    assert_equal(:gfa1, "S\tA\tNNNN".to_rgfa_line(version: :gfa1).version)
    assert_equal(:gfa2, "S\tA\t1\tNNNN".to_rgfa_line(version: :gfa2).version)
    assert_raises(RGFA::FormatError){
      "S\tA\t1\tNNNN".to_rgfa_line(version: :gfa1)}
    assert_raises(RGFA::FormatError){
      "S\tA\tNNNN".to_rgfa_line(version: :gfa2)}
  end

  def test_link
    assert_equal(:gfa1, "L\tA\t+\tB\t-\t*".to_rgfa_line.version)
    assert_equal(:gfa1,
                 "L\tA\t+\tB\t-\t*".to_rgfa_line(version: :gfa1).version)
    l = "L\tA\t+\tB\t-\t*".to_rgfa_line(version: :gfa2)
    assert_equal(RGFA::Line::CustomRecord, l.class)
    assert_raises(RGFA::VersionError){
      RGFA::Line::Edge::Link.new(["A","+","B","-","*"], version: :gfa2)}
  end

  def test_containment
    assert_equal(:gfa1, "C\tA\t+\tB\t-\t10\t*".to_rgfa_line.version)
    assert_equal(:gfa1,
                 "C\tA\t+\tB\t-\t10\t*".to_rgfa_line(version: :gfa1).version)
    c = "C\tA\t+\tB\t-\t10\t*".to_rgfa_line(version: :gfa2)
    assert_equal(RGFA::Line::CustomRecord, c.class)
    assert_raises(RGFA::VersionError){
      RGFA::Line::Edge::Containment.new(["A","+","B","-","10","*"], version: :gfa2)}
  end

  def test_custom_record
    assert_equal(:gfa2, "X\tVN:Z:1.0".to_rgfa_line.version)
    assert_equal(:gfa2, "X\tVN:Z:1.0".to_rgfa_line(version: :gfa2).version)
    assert_raises(RGFA::TypeError){
      "X\tVN:Z:1.0".to_rgfa_line(version: :gfa1)}
    assert_raises(RGFA::VersionError){
      RGFA::Line::CustomRecord.new(["X","VN:Z:1.0"], version: :gfa1)}
  end

end
