require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFALineLink < Test::Unit::TestCase

  def test_from_string
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
      f=fields.dup; f[2]="x"; f.join("\t").to_rgfa_line(validate: 3)
    end
    assert_raises(RGFA::FormatError) do
      f=fields.dup; f[4]="x"; f.join("\t").to_rgfa_line(validate: 3)
    end
    assert_raises(RGFA::FormatError) do
      f=fields.dup; f[5]="x"; f.join("\t").to_rgfa_line(validate: 3)
    end
    assert_raises(RGFA::TypeError) do
      f=fields.dup; f[6]="RC:Z:1232"; f.join("\t").to_rgfa_line(validate: 3)
    end
    assert_raises(RGFA::TypeError) do
      f=fields.dup; f[7]="NM:Z:1232"; f.join("\t").to_rgfa_line(validate: 3)
    end
  end

  def test_coords
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

  def test_to_gfa2
    g = RGFA.new(version: :gfa1)
    g << "S\t1\t*\tLN:i:100"
    g << "S\t2\t*\tLN:i:100"
    g << "S\t3\t*\tLN:i:100"
    g << "S\t4\t*\tLN:i:100"
    g << "L\t1\t+\t2\t+\t10M"
    g << "L\t1\t-\t2\t-\t20M"
    g << "L\t3\t-\t4\t+\t30M"
    g << "L\t3\t+\t4\t-\t40M"
    assert_equal("E	*	1+	2+	90	100$	0	10	10M",
                 g.links[0].to_gfa2_s)
    assert_equal("E	*	1-	2-	0	20	80	100$	20M",
                 g.links[1].to_gfa2_s)
    assert_equal("E	*	3-	4+	0	30	0	30	30M",
                 g.links[2].to_gfa2_s)
    assert_equal("E	*	3+	4-	60	100$	60	100$	40M",
                 g.links[3].to_gfa2_s)
    assert_equal(RGFA::Line::Edge::Link, g.links[0].to_gfa1.class)
    assert_equal(RGFA::Line::Edge::GFA2, g.links[0].to_gfa2.class)
  end

  def test_link_other
    l = "L\t1\t+\t2\t-\t*".to_rgfa_line
    assert_equal(:"2", l.other(:"1"))
    assert_equal(:"1", l.other(:"2"))
    assert_raise(RGFA::NotFoundError){l.other(:"0")}
  end

  def test_link_circular
    l = "L\t1\t+\t2\t-\t*".to_rgfa_line
    assert_equal(false, l.circular?)
    l = "L\t1\t+\t1\t-\t*".to_rgfa_line
    assert_equal(true, l.circular?)
  end

end
