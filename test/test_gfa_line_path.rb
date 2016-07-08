require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFALinePath < Test::Unit::TestCase

  def test_from_string
    fields=["P","4","1+,2-,3+","9M2I3D1M,12M,12M","ab:Z:abcd"]
    str=fields.join("\t")
    assert_nothing_raised { str.to_rgfa_line }
    assert_equal(RGFA::Line::Path, str.to_rgfa_line.class)
    assert_equal(fields[0], str.to_rgfa_line.record_type)
    assert_equal(fields[1], str.to_rgfa_line.path_name)
    assert_equal(fields[2], str.to_rgfa_line.segment_names(false))
    assert_equal([["1","+"],["2","-"],["3","+"]], str.to_rgfa_line.segment_names)
    assert_equal(fields[3], str.to_rgfa_line.cigars(false))
    assert_equal([[[9,"M"],[2,"I"],[3,"D"],[1,"M"]],[[12,"M"]],[[12,"M"]]],
                 str.to_rgfa_line.cigars)
    assert_equal("abcd", str.to_rgfa_line.ab)
    assert_raises(TypeError) { (str+"\tH1").to_rgfa_line }
    assert_raises(RGFA::Line::RequiredFieldMissingError) { "P\tH".to_rgfa_line }
    assert_raises(RGFA::Line::RequiredFieldTypeError) do
      f=fields.dup; f[2]="1,2,3"; f.join("\t").to_rgfa_line
    end
    assert_nothing_raised do
      f=fields.dup; f[2]="1+"; f.join("\t").to_rgfa_line
    end
    assert_nothing_raised do
      f=fields.dup; f[3]="*"; f.join("\t").to_rgfa_line
    end
    assert_raises(RGFA::Line::RequiredFieldTypeError) do
      f=fields.dup; f[3]="12,12,20"; f.join("\t").to_rgfa_line
    end
    assert_raises(RGFA::Line::RequiredFieldTypeError) do
      f=fields.dup; f[3]="12M|12M|12M"; f.join("\t").to_rgfa_line
    end
  end

end
