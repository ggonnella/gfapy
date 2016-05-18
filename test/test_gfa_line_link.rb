require_relative "../lib/gfa.rb"
require "test/unit"

class TestGFALineLink < Test::Unit::TestCase

  def test_from_string
    fields=["L","1","+","2","-","12M","RC:i:1232","NM:i:3","ab:Z:abcd",
            "FC:i:2321","KC:i:1212","MQ:i:40"]
    str=fields.join("\t")
    assert_nothing_raised { str.to_gfa_line }
    assert_equal(GFA::Line::Link, str.to_gfa_line.class)
    assert_equal(fields[0], str.to_gfa_line.record_type)
    assert_equal(fields[1], str.to_gfa_line.from)
    assert_equal(fields[2], str.to_gfa_line.from_orient)
    assert_equal(fields[3], str.to_gfa_line.to)
    assert_equal(fields[4], str.to_gfa_line.to_orient)
    assert_equal([[12,"M"]], str.to_gfa_line.overlap)
    assert_equal(fields[5], str.to_gfa_line.overlap(false))
    assert_equal(1232, str.to_gfa_line.RC)
    assert_equal(3, str.to_gfa_line.NM)
    assert_equal(2321, str.to_gfa_line.FC)
    assert_equal(1212, str.to_gfa_line.KC)
    assert_equal(40, str.to_gfa_line.MQ)
    assert_equal("abcd", str.to_gfa_line.ab)
    assert_raises(TypeError) { (str+"\tH1").to_gfa_line }
    assert_raises(GFA::Line::RequiredFieldMissingError) { "L\tH".to_gfa_line }
    assert_raises(GFA::Line::RequiredFieldTypeError) do
      f=fields.dup; f[2]="x"; f.join("\t").to_gfa_line
    end
    assert_raises(GFA::Line::RequiredFieldTypeError) do
      f=fields.dup; f[4]="x"; f.join("\t").to_gfa_line
    end
    assert_raises(GFA::Line::RequiredFieldTypeError) do
      f=fields.dup; f[5]="x"; f.join("\t").to_gfa_line
    end
    assert_raises(GFA::Line::PredefinedOptfieldTypeError) do
      f=fields.dup; f[6]="RC:Z:1232"; f.join("\t").to_gfa_line
    end
    assert_raises(GFA::Line::PredefinedOptfieldTypeError) do
      f=fields.dup; f[7]="NM:Z:1232"; f.join("\t").to_gfa_line
    end
  end

end
