require_relative "../lib/gfa.rb"
require "test/unit"

class TestGFALineSegment < Test::Unit::TestCase

  def test_from_string
    fields=["S","1","ACGTCACANNN","RC:i:1232","LN:i:11","ab:Z:abcd",
            "FC:i:2321","KC:i:1212"]
    str=fields.join("\t")
    assert_nothing_raised { str.to_gfa_line }
    assert_equal(GFA::Line::Segment, str.to_gfa_line.class)
    assert_equal(fields[0], str.to_gfa_line.record_type)
    assert_equal(fields[1], str.to_gfa_line.name)
    assert_equal(fields[2], str.to_gfa_line.sequence)
    assert_equal(1232, str.to_gfa_line.RC)
    assert_equal(11, str.to_gfa_line.LN)
    assert_equal(2321, str.to_gfa_line.FC)
    assert_equal(1212, str.to_gfa_line.KC)
    assert_equal("abcd", str.to_gfa_line.ab)
    assert_raises(TypeError) { (str+"\tH1").to_gfa_line }
    assert_raises(GFA::Line::RequiredFieldMissingError) { "S\tH".to_gfa_line }
    assert_raises(GFA::Line::RequiredFieldTypeError) do
      f=fields.dup; f[2]="!@#?"; f.join("\t").to_gfa_line
    end
    assert_raises(GFA::Line::PredefinedOptfieldTypeError) do
      f=fields.dup; f[3]="RC:Z:1232"; f.join("\t").to_gfa_line
    end
  end

end
