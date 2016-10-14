require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFALineVersion < Test::Unit::TestCase

  def test_header
    assert_equal(:generic, "H\tVN:Z:1.0".to_rgfa_line.version)
    assert_equal(:"1.0", "H\tVN:Z:1.0".to_rgfa_line(version: :"1.0").version)
    assert_equal(:"2.0", "H\tVN:Z:1.0".to_rgfa_line(version: :"2.0").version)
  end

  def test_comment
    assert_equal(:generic, "# VN:Z:1.0".to_rgfa_line.version)
    assert_equal(:"1.0", "# VN:Z:1.0".to_rgfa_line(version: :"1.0").version)
    assert_equal(:"2.0", "# VN:Z:1.0".to_rgfa_line(version: :"2.0").version)
  end

  def test_segment
    assert_equal(:"1.0", "S\tA\tNNNN".to_rgfa_line.version)
    assert_equal(:"2.0", "S\tA\t1\tNNNN".to_rgfa_line.version)
    assert_equal(:"1.0", "S\tA\tNNNN".to_rgfa_line(version: :"1.0").version)
    assert_equal(:"2.0", "S\tA\t1\tNNNN".to_rgfa_line(version: :"2.0").version)
    assert_raises(RGFA::FieldParser::FormatError){
      "S\tA\t1\tNNNN".to_rgfa_line(version: :"1.0")}
    assert_raises(RGFA::Line::RequiredFieldMissingError){
      "S\tA\tNNNN".to_rgfa_line(version: :"2.0")}
  end

  def test_link
    assert_equal(:"1.0", "L\tA\t+\tB\t-\t*".to_rgfa_line.version)
    assert_equal(:"1.0",
                 "L\tA\t+\tB\t-\t*".to_rgfa_line(version: :"1.0").version)
    l = "L\tA\t+\tB\t-\t*".to_rgfa_line(version: :"2.0")
    assert_equal(RGFA::Line::CustomRecord, l.class)
    assert_raises(RGFA::VersionError){
      RGFA::Line::Link.new(["A","+","B","-","*"], version: :"2.0")}
  end

  def test_containment
    assert_equal(:"1.0", "C\tA\t+\tB\t-\t10\t*".to_rgfa_line.version)
    assert_equal(:"1.0",
                 "C\tA\t+\tB\t-\t10\t*".to_rgfa_line(version: :"1.0").version)
    c = "C\tA\t+\tB\t-\t10\t*".to_rgfa_line(version: :"2.0")
    assert_equal(RGFA::Line::CustomRecord, c.class)
    assert_raises(RGFA::VersionError){
      RGFA::Line::Containment.new(["A","+","B","-","10","*"], version: :"2.0")}
  end

  def test_custom_record
    assert_equal(:"2.0", "X\tVN:Z:1.0".to_rgfa_line.version)
    assert_equal(:"2.0", "X\tVN:Z:1.0".to_rgfa_line(version: :"2.0").version)
    assert_raises(RGFA::Line::UnknownRecordTypeError){
      "X\tVN:Z:1.0".to_rgfa_line(version: :"1.0")}
    assert_raises(RGFA::VersionError){
      RGFA::Line::CustomRecord.new(["X","VN:Z:1.0"], version: :"1.0")}
  end

end
