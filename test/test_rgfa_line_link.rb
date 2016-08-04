require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFALineLink < Test::Unit::TestCase

  def test_from_string
    fields=["L","1","+","2","-","12M","RC:i:1232","NM:i:3","ab:Z:abcd",
            "FC:i:2321","KC:i:1212","MQ:i:40"]
    str=fields.join("\t")
    assert_nothing_raised { str.to_rgfa_line }
    assert_equal(RGFA::Line::Link, str.to_rgfa_line.class)
    assert_equal(fields[0].to_sym, str.to_rgfa_line.record_type)
    assert_equal(fields[1].to_sym, str.to_rgfa_line.from)
    assert_equal(fields[2].to_sym, str.to_rgfa_line.from_orient)
    assert_equal(fields[3].to_sym, str.to_rgfa_line.to)
    assert_equal(fields[4].to_sym, str.to_rgfa_line.to_orient)
    assert_equal([RGFA::CIGAR::Operation.new(12,:M)], str.to_rgfa_line.overlap)
    assert_equal(1232, str.to_rgfa_line.RC)
    assert_equal(3, str.to_rgfa_line.NM)
    assert_equal(2321, str.to_rgfa_line.FC)
    assert_equal(1212, str.to_rgfa_line.KC)
    assert_equal(40, str.to_rgfa_line.MQ)
    assert_equal("abcd", str.to_rgfa_line.ab)
    assert_raises(RGFA::FieldParser::FormatError) { (str+"\tH1").to_rgfa_line }
    assert_raises(RGFA::Line::RequiredFieldMissingError) { "L\tH".to_rgfa_line }
    assert_raises(RGFA::FieldParser::FormatError) do
      f=fields.dup; f[2]="x"; f.join("\t").to_rgfa_line(validate: 3)
    end
    assert_raises(RGFA::FieldParser::FormatError) do
      f=fields.dup; f[4]="x"; f.join("\t").to_rgfa_line(validate: 3)
    end
    assert_raises(RGFA::CIGAR::ValueError) do
      f=fields.dup; f[5]="x"; f.join("\t").to_rgfa_line(validate: 3)
    end
    assert_raises(RGFA::Line::PredefinedOptfieldTypeError) do
      f=fields.dup; f[6]="RC:Z:1232"; f.join("\t").to_rgfa_line(validate: 3)
    end
    assert_raises(RGFA::Line::PredefinedOptfieldTypeError) do
      f=fields.dup; f[7]="NM:Z:1232"; f.join("\t").to_rgfa_line(validate: 3)
    end
  end

end
