require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFAVersion < Test::Unit::TestCase

  def test_init_without_version_by_init
    gfa = RGFA.new()
    assert_equal(nil, gfa.version)
  end

  def test_init_GFA1
    gfa = RGFA.new(version: :"1.0")
    assert_equal(:"1.0", gfa.version)
  end

  def test_init_GFA2
    gfa = RGFA.new(version: :"2.0")
    assert_equal(:"2.0", gfa.version)
  end

  def test_init_invalid_version
    assert_raises(RGFA::VersionError) { RGFA.new(version: :"x.x") }
  end

  def test_GFA1_header
    hother = "H\taa:A:a\tff:f:1.1"
    hv1 = "H\tzz:Z:test\tVN:Z:1.0\tii:i:11"
    gfa = RGFA.new()
    gfa << hother
    assert_equal(nil, gfa.version)
    gfa << hv1
    assert_equal(:"1.0", gfa.version)
  end

  def test_GFA2_header
    hother = "H\taa:A:a\tff:f:1.1"
    hv2 = "H\tzz:Z:test\tVN:Z:2.0\tii:i:11"
    gfa = RGFA.new()
    gfa << hother
    assert_equal(nil, gfa.version)
    gfa << hv2
    assert_equal(:"2.0", gfa.version)
  end

  def test_unknown_version_in_header
    hother = "H\taa:A:a\tff:f:1.1"
    hvx = "H\tzz:Z:test\tVN:Z:x.x\tii:i:11"
    gfa = RGFA.new()
    gfa << hother
    assert_equal(nil, gfa.version)
    assert_raises(RGFA::VersionError) { gfa << hvx }
  end

  def test_wrong_version_in_header
    hother = "H\taa:A:a\tff:f:1.1"
    hv2 = "H\tzz:Z:test\tVN:Z:2.0\tii:i:11"
    gfa = RGFA.new(version: :"1.0")
    gfa << hother
    assert_equal(:"1.0", gfa.version)
    assert_raises(RGFA::VersionError) { gfa << hv2 }
  end

  def test_conflicting_versions_in_header
    hother = "H\taa:A:a\tff:f:1.1"
    hv1 = "H\tzz:Z:test\tVN:Z:1.0\tii:i:11"
    hv2 = "H\tzz:Z:test\tVN:Z:2.0\tii:i:11"
    gfa = RGFA.new()
    gfa << hother
    gfa << hv1
    assert_raises(RGFA::VersionError) { gfa << hv2 }
  end

  def test_version_by_segment_GFA1_syntax
    sv1 = "S\tA\t*"
    gfa = RGFA.new()
    gfa << sv1
    assert_equal(:"1.0", gfa.version)
  end

  def test_version_by_segment_GFA2_syntax
    sv2 = "S\tB\t100\t*"
    gfa = RGFA.new()
    gfa << sv2
    assert_equal(:"2.0", gfa.version)
  end

  def test_GFA2_segment_in_GFA1
    sv1 = "S\tA\t*"
    sv2 = "S\tB\t100\t*"
    gfa = RGFA.new()
    gfa << sv1
    assert_raises(RGFA::FormatError) { gfa << sv2 }
  end

  def test_GFA1_segment_in_GFA2
    sv1 = "S\tA\t*"
    sv2 = "S\tB\t100\t*"
    gfa = RGFA.new()
    gfa << sv2
    assert_raises(RGFA::FormatError) { gfa << sv1 }
  end

  def test_version_by_GFA2_specific_line_E
    e = "E\t*\tA+\tB+\t0\t10\t20\t30\t*"
    gfa = RGFA.new()
    gfa << e
    assert_equal(:"2.0", gfa.version)
  end

  def test_version_by_GFA2_specific_line_G
    g = "G\t*\tA\t<\t>\tB\t1000\t*"
    gfa = RGFA.new()
    gfa << g
    assert_equal(:"2.0", gfa.version)
  end

  def test_version_by_GFA2_specific_line_F
    f = "F\tX\tID+\t10\t100\t0\t90$\t*"
    gfa = RGFA.new()
    gfa << f
    assert_equal(:"2.0", gfa.version)
  end

  def test_version_by_GFA2_specific_line_O
    o = "O\tX\tA B C"
    gfa = RGFA.new()
    gfa << o
    assert_equal(:"2.0", gfa.version)
  end

  def test_version_by_GFA2_specific_line_U
    u = "U\tX\tA B C"
    gfa = RGFA.new()
    gfa << u
    assert_equal(:"2.0", gfa.version)
  end

  def test_version_guess_GFA1_specific_line
    l = "L\tA\t-\tB\t+\t*"
    gfa = RGFA.new()
    gfa << l
    gfa.process_line_queue
    assert_equal(:"1.0", gfa.version)
  end

  def test_version_guess_default
    gfa = RGFA.new()
    gfa.process_line_queue
    assert_equal(:"2.0", gfa.version)
  end

end
