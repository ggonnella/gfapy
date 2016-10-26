require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFALinePath < Test::Unit::TestCase

  def test_from_string
    fields=["P","4","1+,2-,3+","9M2I3D1M,12M","ab:Z:abcd"]
    str=fields.join("\t")
    assert_nothing_raised { str.to_rgfa_line }
    assert_equal(RGFA::Line::Path, str.to_rgfa_line.class)
    assert_equal(fields[0].to_sym, str.to_rgfa_line.record_type)
    assert_equal(fields[1].to_sym, str.to_rgfa_line.path_name)
    assert_equal([[:"1",:"+"],[:"2",:"-"],[:"3",:"+"]],
                 str.to_rgfa_line.segment_names)
    assert_equal([[RGFA::CIGAR::Operation.new(9,:M),
                   RGFA::CIGAR::Operation.new(2,:I),
                   RGFA::CIGAR::Operation.new(3,:D),
                   RGFA::CIGAR::Operation.new(1,:M)],
                  [RGFA::CIGAR::Operation.new(12,:M)]],
                 str.to_rgfa_line.overlaps)
    assert_equal("abcd", str.to_rgfa_line.ab)
    assert_raises(RGFA::FormatError) { (str+"\tH1").to_rgfa_line }
    assert_raises(RGFA::FormatError) { "P\tH".to_rgfa_line }
    assert_raises(RGFA::FormatError) do
      f=fields.dup; f[2]="1,2,3"; f.join("\t").to_rgfa_line(validate: 3)
    end
    assert_raises(RGFA::InconsistencyError) do
      f=fields.dup; f[2]="1+,2+"; f[3]="9M,12M,3M";
                    f.join("\t").to_rgfa_line(validate: 3)
    end
    assert_nothing_raised do
      f=fields.dup; f[3]="*,*"; f.join("\t").to_rgfa_line(validate: 3)
    end
    assert_nothing_raised do
      f=fields.dup; f[3]="9M2I3D1M,12M,12M"; f.join("\t").
        to_rgfa_line(validate: 3)
    end
    assert_nothing_raised do
      f=fields.dup; f[3]="*"; f.join("\t").to_rgfa_line(validate: 3)
    end
    assert_raises(RGFA::FormatError) do
      f=fields.dup; f[3]="12,12"; f.join("\t").to_rgfa_line(validate: 3)
    end
    assert_raises(RGFA::FormatError) do
      f=fields.dup; f[3]="12M|12M"; f.join("\t").to_rgfa_line(validate: 3)
    end
  end

end
