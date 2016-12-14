require_relative "../lib/rgfa.rb"
require "test/unit"

TestAPI ||= Module.new

class TestAPI::GFA2Lines < Test::Unit::TestCase

  def test_S
    fields=["S","1","ACGTCACANNN","RC:i:1232","LN:i:11","ab:Z:abcd",
            "FC:i:2321","KC:i:1212"]
    str=fields.join("\t")
    assert_nothing_raised { str.to_rgfa_line }
    assert_equal(RGFA::Line::Segment::GFA1, str.to_rgfa_line.class)
    assert_equal(fields[0].to_sym, str.to_rgfa_line.record_type)
    assert_equal(fields[1].to_sym, str.to_rgfa_line.name)
    assert_equal(fields[2], str.to_rgfa_line.sequence)
    assert_equal(1232, str.to_rgfa_line.RC)
    assert_equal(11, str.to_rgfa_line.LN)
    assert_equal(2321, str.to_rgfa_line.FC)
    assert_equal(1212, str.to_rgfa_line.KC)
    assert_equal("abcd", str.to_rgfa_line.ab)
    assert_raises(RGFA::FormatError) { (str+"\tH1").to_rgfa_line }
    assert_raises(RGFA::FormatError) { "S\tH".to_rgfa_line }
    assert_raises(RGFA::FormatError) do
      f=fields.dup; f[2]="!@#?"; f.join("\t").to_rgfa_line(vlevel: 3)
    end
    assert_raises(RGFA::TypeError) do
      f=fields.dup; f[3]="RC:Z:1232"; f.join("\t").to_rgfa_line(version: :gfa1)
    end
    f=["S","2","ACGTCACANNN","LN:i:3"]
    assert_raises(RGFA::InconsistencyError) do
      f.join("\t").to_rgfa_line(vlevel: 3, version: :gfa1)
    end
    f=["S","2","ACGTCACANNN","LN:i:11"]
    assert_nothing_raised { f.join("\t").to_rgfa_line }
    f=["S","2","*","LN:i:3"]
    assert_nothing_raised { f.join("\t").to_rgfa_line }
  end

  def test_coverage
    l = "S\t0\t*\tRC:i:600\tLN:i:100".to_rgfa_line
    assert_equal(6, l.coverage)
    assert_equal(6, l.coverage!)
    l = "S\t0\t*\tRC:i:600".to_rgfa_line
    assert_equal(nil, l.coverage)
    assert_raises(RGFA::NotFoundError) {l.coverage!}
    l = "S\t0\t*\tLN:i:100".to_rgfa_line
    assert_equal(nil, l.coverage)
    assert_raises(RGFA::NotFoundError) {l.coverage!}
    l = "S\t0\t*\tFC:i:600\tLN:i:100".to_rgfa_line
    assert_equal(nil, l.coverage)
    assert_raises(RGFA::NotFoundError) {l.coverage!}
    assert_equal(6, l.coverage(count_tag: :FC))
    assert_equal(6, l.coverage!(count_tag: :FC))
  end

end
