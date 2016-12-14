require_relative "../lib/rgfa.rb"
require "test/unit"

TestAPI ||= Module.new

class TestAPI::GFA1Lines < Test::Unit::TestCase

  def test_C
    fields=["C","1","+","2","-","12","12M","MQ:i:1232","NM:i:3","ab:Z:abcd"]
    str=fields.join("\t")
    assert_nothing_raised { str.to_rgfa_line }
    assert_equal(RGFA::Line::Edge::Containment, str.to_rgfa_line.class)
    assert_equal(fields[0].to_sym, str.to_rgfa_line.record_type)
    assert_equal(fields[1].to_sym, str.to_rgfa_line.from)
    assert_equal(fields[2].to_sym, str.to_rgfa_line.from_orient)
    assert_equal(fields[3].to_sym, str.to_rgfa_line.to)
    assert_equal(fields[4].to_sym, str.to_rgfa_line.to_orient)
    assert_equal(12, str.to_rgfa_line.pos)
    assert_equal([RGFA::Alignment::CIGAR::Operation.new(12,:M)], str.to_rgfa_line.overlap)
    assert_equal(1232, str.to_rgfa_line.MQ)
    assert_equal(3, str.to_rgfa_line.NM)
    assert_equal("abcd", str.to_rgfa_line.ab)
    assert_raises(RGFA::FormatError) { (str+"\tH1").to_rgfa_line }
    assert_raises(RGFA::FormatError) { "C\tH".to_rgfa_line }
    assert_raises(RGFA::FormatError) do
      f=fields.dup; f[2]="x"; f.join("\t").to_rgfa_line(vlevel: 1)
    end
    assert_raises(RGFA::FormatError) do
      f=fields.dup; f[4]="x"; f.join("\t").to_rgfa_line(vlevel: 1)
    end
    assert_raises(RGFA::FormatError) do
      f=fields.dup; f[5]="x"; f.join("\t").to_rgfa_line(vlevel: 1)
    end
    assert_raises(RGFA::FormatError) do
      f=fields.dup; f[6]="x"; f.join("\t").to_rgfa_line(vlevel: 1)
    end
    assert_raises(RGFA::TypeError) do
      f=fields.dup; f[7]="MQ:Z:1232"; f.join("\t").to_rgfa_line(vlevel: 1)
    end
    assert_raises(RGFA::TypeError) do
      f=fields.dup; f[8]="NM:Z:1232"; f.join("\t").to_rgfa_line(vlevel: 1)
    end
  end

  def test_L
    fields=["L","1","+","2","-","12M","RC:i:1232","NM:i:3","ab:Z:abcd",
            "FC:i:2321","KC:i:1212","MQ:i:40"]
    str=fields.join("\t")
    assert_nothing_raised { str.to_rgfa_line }
    assert_equal(RGFA::Line::Edge::Link, str.to_rgfa_line.class)
    assert_equal(fields[0].to_sym, str.to_rgfa_line.record_type)
    assert_equal(fields[1].to_sym, str.to_rgfa_line.from)
    assert_equal(fields[2].to_sym, str.to_rgfa_line.from_orient)
    assert_equal(fields[3].to_sym, str.to_rgfa_line.to)
    assert_equal(fields[4].to_sym, str.to_rgfa_line.to_orient)
    assert_equal([RGFA::Alignment::CIGAR::Operation.new(12,:M)],
                 str.to_rgfa_line.overlap)
    assert_equal(1232, str.to_rgfa_line.RC)
    assert_equal(3, str.to_rgfa_line.NM)
    assert_equal(2321, str.to_rgfa_line.FC)
    assert_equal(1212, str.to_rgfa_line.KC)
    assert_equal(40, str.to_rgfa_line.MQ)
    assert_equal("abcd", str.to_rgfa_line.ab)
    assert_raises(RGFA::FormatError) { (str+"\tH1").to_rgfa_line }
    assert_raises(RGFA::FormatError) { "L\tH".to_rgfa_line }
    assert_raises(RGFA::FormatError) do
      f=fields.dup; f[2]="x"; f.join("\t").to_rgfa_line(vlevel: 1)
    end
    assert_raises(RGFA::FormatError) do
      f=fields.dup; f[4]="x"; f.join("\t").to_rgfa_line(vlevel: 1)
    end
    assert_raises(RGFA::FormatError) do
      f=fields.dup; f[5]="x"; f.join("\t").to_rgfa_line(vlevel: 1)
    end
    assert_raises(RGFA::TypeError) do
      f=fields.dup; f[6]="RC:Z:1232"; f.join("\t").to_rgfa_line(vlevel: 1)
    end
    assert_raises(RGFA::TypeError) do
      f=fields.dup; f[7]="NM:Z:1232"; f.join("\t").to_rgfa_line(vlevel: 1)
    end
  end

  def test_L_coords
    g = RGFA.new(version: :gfa1)
    g << "S\t1\t*\tLN:i:100"
    g << "L\t1\t+\t2\t-\t1M2D10M1I"
    assert_equal([87,100], g.links[0].from_coords)
    assert_raises(RGFA::ValueError) {g.links[0].to_coords}
    g << "S\t2\t*\tLN:i:100"
    assert_equal([88,100], g.links[0].to_coords)
    g << "L\t3\t-\t4\t+\t10M2P3D1M"
    assert_equal([0,14], g.links[1].from_coords)
    assert_equal([0,11], g.links[1].to_coords)
  end

  def test_L_other
    l = "L\t1\t+\t2\t-\t*".to_rgfa_line
    assert_equal(:"2", l.other(:"1"))
    assert_equal(:"1", l.other(:"2"))
    assert_raise(RGFA::NotFoundError){l.other(:"0")}
  end

  def test_L_circular
    l = "L\t1\t+\t2\t-\t*".to_rgfa_line
    assert_equal(false, l.circular?)
    l = "L\t1\t+\t1\t-\t*".to_rgfa_line
    assert_equal(true, l.circular?)
  end

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
      f=fields.dup; f[2]="!@#?"; f.join("\t").to_rgfa_line(vlevel: 1)
    end
    assert_raises(RGFA::TypeError) do
      f=fields.dup; f[3]="RC:Z:1232"; f.join("\t").to_rgfa_line(version: :gfa1)
    end
    f=["S","2","ACGTCACANNN","LN:i:3"]
    assert_raises(RGFA::InconsistencyError) do
      f.join("\t").to_rgfa_line(vlevel: 1, version: :gfa1)
    end
    f=["S","2","ACGTCACANNN","LN:i:11"]
    assert_nothing_raised { f.join("\t").to_rgfa_line }
    f=["S","2","*","LN:i:3"]
    assert_nothing_raised { f.join("\t").to_rgfa_line }
  end

  def test_forbidden_segment_names
    assert_nothing_raised { "S\tA+B\t*".to_rgfa_line }
    assert_nothing_raised { "S\tA-B\t*".to_rgfa_line }
    assert_nothing_raised { "S\tA,B\t*".to_rgfa_line }
    assert_raises(RGFA::FormatError) do
      "S\tA+,B\t*".to_rgfa_line(vlevel: 1)
    end
    assert_raises(RGFA::FormatError) do
      "S\tA-,B\t*".to_rgfa_line(vlevel: 1)
    end
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

  def test_P
    fields=["P","4","1+,2-,3+","9M2I3D1M,12M","ab:Z:abcd"]
    str=fields.join("\t")
    assert_nothing_raised { str.to_rgfa_line }
    assert_equal(RGFA::Line::Group::Path, str.to_rgfa_line.class)
    assert_equal(fields[0].to_sym, str.to_rgfa_line.record_type)
    assert_equal(fields[1].to_sym, str.to_rgfa_line.path_name)
    assert_equal([OL[:"1",:"+"],OL[:"2",:"-"],OL[:"3",:"+"]],
                 str.to_rgfa_line.segment_names)
    assert_equal([[RGFA::Alignment::CIGAR::Operation.new(9,:M),
                   RGFA::Alignment::CIGAR::Operation.new(2,:I),
                   RGFA::Alignment::CIGAR::Operation.new(3,:D),
                   RGFA::Alignment::CIGAR::Operation.new(1,:M)],
                  [RGFA::Alignment::CIGAR::Operation.new(12,:M)]],
                 str.to_rgfa_line.overlaps)
    assert_equal("abcd", str.to_rgfa_line.ab)
    assert_raises(RGFA::FormatError) { (str+"\tH1").to_rgfa_line }
    assert_raises(RGFA::FormatError) { "P\tH".to_rgfa_line }
    assert_raises(RGFA::FormatError) do
      f=fields.dup; f[2]="1,2,3"; f.join("\t").to_rgfa_line(vlevel: 1)
    end
    assert_raises(RGFA::InconsistencyError) do
      f=fields.dup; f[2]="1+,2+"; f[3]="9M,12M,3M";
                    f.join("\t").to_rgfa_line(vlevel: 1)
    end
    assert_nothing_raised do
      f=fields.dup; f[3]="*,*"; f.join("\t").to_rgfa_line(vlevel: 1)
    end
    assert_nothing_raised do
      f=fields.dup; f[3]="9M2I3D1M,12M,12M"; f.join("\t").
        to_rgfa_line(vlevel: 3)
    end
    assert_nothing_raised do
      f=fields.dup; f[3]="*"; f.join("\t").to_rgfa_line(vlevel: 1)
    end
    assert_raises(RGFA::FormatError) do
      f=fields.dup; f[3]="12,12"; f.join("\t").to_rgfa_line(vlevel: 1)
    end
    assert_raises(RGFA::FormatError) do
      f=fields.dup; f[3]="12M|12M"; f.join("\t").to_rgfa_line(vlevel: 1)
    end
  end

end
