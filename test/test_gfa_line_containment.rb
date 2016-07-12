require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFALineContainment < Test::Unit::TestCase

  def test_from_string
    fields=["C","1","+","2","-","12","12M","MQ:i:1232","NM:i:3","ab:Z:abcd"]
    str=fields.join("\t")
    assert_nothing_raised { str.to_rgfa_line }
    assert_equal(RGFA::Line::Containment, str.to_rgfa_line.class)
    assert_equal(fields[0], str.to_rgfa_line.record_type)
    assert_equal(fields[1].to_sym, str.to_rgfa_line.from)
    assert_equal(fields[2].to_sym, str.to_rgfa_line.from_orient)
    assert_equal(fields[3].to_sym, str.to_rgfa_line.to)
    assert_equal(fields[4].to_sym, str.to_rgfa_line.to_orient)
    assert_equal(12, str.to_rgfa_line.pos)
    assert_equal([[12,"M"]], str.to_rgfa_line.overlap)
    assert_equal(1232, str.to_rgfa_line.MQ)
    assert_equal(3, str.to_rgfa_line.NM)
    assert_equal("abcd", str.to_rgfa_line.ab)
    assert_raises(RGFA::Line::FieldFormatError) { (str+"\tH1").to_rgfa_line }
    assert_raises(RGFA::Line::RequiredFieldMissingError) { "C\tH".to_rgfa_line }
    assert_raises(RGFA::Line::FieldFormatError) do
      f=fields.dup; f[2]="x"; f.join("\t").to_rgfa_line
    end
    assert_raises(RGFA::Line::FieldFormatError) do
      f=fields.dup; f[4]="x"; f.join("\t").to_rgfa_line
    end
    assert_raises(RGFA::Line::FieldFormatError) do
      f=fields.dup; f[5]="x"; f.join("\t").to_rgfa_line
    end
    assert_raises(RGFA::Line::FieldFormatError) do
      f=fields.dup; f[6]="x"; f.join("\t").to_rgfa_line
    end
    assert_raises(RGFA::Line::PredefinedOptfieldTypeError) do
      f=fields.dup; f[7]="MQ:Z:1232"; f.join("\t").to_rgfa_line
    end
    assert_raises(RGFA::Line::PredefinedOptfieldTypeError) do
      f=fields.dup; f[8]="NM:Z:1232"; f.join("\t").to_rgfa_line
    end
  end

end
