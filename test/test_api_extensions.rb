require_relative "../lib/rgfa.rb"
require "test/unit"
TestAPI ||= Module.new

class TestAPI::Extensions < Test::Unit::TestCase

  require_relative "./extension"

  def test_extensions
    g = RGFA.new(version: :gfa2)
    RGFA::Line::MetagenomicAssignment.new(["*","N12","C","20"])
    g << (sA = "S\tA\t1000\t*".to_rgfa_line)
    g << (tB12 = "T\tB12_c\tB12 common strain".to_rgfa_line)
    g << (m1 = "M\t1\ttaxon:123\tA\t40\txx:Z:cjaks536".to_rgfa_line)
    g << (m2 = "M\t2\ttaxon:123\tB\t*\txx:Z:cga5r5cs".to_rgfa_line)
    g << (sB = "S\tB\t1000\t*".to_rgfa_line)
    g << (mx = "M\t*\tB12_c\tB\t20".to_rgfa_line)
    g << (t123 = "T\ttaxon:123\tSpecies 123\tUL:Z:http://www.taxon123.com".
                 to_rgfa_line)
    assert_equal(RGFA::Line::MetagenomicAssignment, m1.class)
    assert_equal(RGFA::Line::Taxon, tB12.class)
    assert_equal(:"1", m1.mid)
    assert(mx.mid.placeholder?)
    assert_equal(t123, m1.tid)
    assert_equal(sA, m1.sid)
    assert_equal("cjaks536", m1.xx)
    assert_equal([m2,mx], sB.metagenomic_assignments)
    assert_equal([m1,m2], t123.metagenomic_assignments)
    assert_equal(:"taxon:123", t123.tid)
    assert_equal("Species 123", t123.desc)
    assert_equal("http://www.taxon123.com", t123.UL)
  end

  #require_relative "./disable_extension"

end
