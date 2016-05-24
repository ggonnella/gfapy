require_relative "../lib/gfa.rb"
require "test/unit"

class TestGFALine < Test::Unit::TestCase

  def test_initialize_line
    l = GFA::Line.new(["H"],[[:record_type, /H/]],{})
    assert(l)
  end

  def test_initialize_unknown_record_type
    assert_raise(GFA::Line::UnknownRecordTypeError) do
      GFA::Line.new(["A"],[[:record_type, /[A-Z]/]],{})
    end
  end

  def test_initialize_not_enough_required
    assert_nothing_raised do
      GFA::Line.new(["H"],[[:record_type, /[A-Z]/]],{})
    end
    assert_raise(GFA::Line::RequiredFieldMissingError) do
      GFA::Line.new([],[[:record_type, /[A-Z]/]],{})
    end
    assert_raise(GFA::Line::RequiredFieldMissingError) do
      GFA::Line.new(["H"],[[:record_type, /[A-Z]/],[:from, /[0-9]+/]],{})
    end
  end

  def test_initialize_too_many_required
    assert_raise(TypeError) do
      GFA::Line.new(["H","1","2"],
                    [[:record_type, /[A-Z]/],[:from, /[0-9]+/]],{})
    end
  end

  def test_initialize_predefined_optfield_wrong_type
    assert_nothing_raised do
      GFA::Line.new(["H","XX:Z:A"],[[:record_type, /[A-Z]/]],{"XX" => "Z"})
    end
    assert_raise(GFA::Line::PredefinedOptfieldTypeError) do
      GFA::Line.new(["H","XX:i:1"],[[:record_type, /[A-Z]/]],{"XX" => "Z"})
    end
  end

  def test_initialize_wrong_optfield_format
    assert_raise(TypeError) do
      GFA::Line.new(["H","XX Z-A"],
                    [[:record_type, /[A-Z]/]],{"XX" => "Z"})
    end
  end

  def test_initialize_reqfield_invalid_name
    assert_raise(GFA::Line::InvalidFieldNameError) do
      GFA::Line.new(["H","1"],[[:record_type, /[A-Z]/],[:to_s, /[0-9]+/]],{})
    end
  end

  def test_initialize_reqfield_type_error
    assert_raise(GFA::Line::RequiredFieldTypeError) do
      GFA::Line.new(["H","A"],[[:record_type, /[A-Z]/],[:from, /[0-9]+/]],{})
    end
  end

  def test_initialize_optfield_type_error
    assert_raise(GFA::Optfield::ValueError) do
      GFA::Line.new(["H","ZZ:i:12A"],
                    [[:record_type, /[A-Z]/]],{"ZZ" => "i"})
    end
  end

  def test_initialize_duplicate_optfield
    assert_raise(GFA::Line::DuplicateOptfieldNameError) do
      GFA::Line.new(["H","XX:i:1", "XX:i:2"],
                    [[:record_type, /[A-Z]/]],{"XX" => "i"})
    end
    assert_raise(GFA::Line::DuplicateOptfieldNameError) do
      GFA::Line.new(["H","zz:i:1", "XX:Z:A", "zz:i:2"],
                    [[:record_type, /[A-Z]/]],{"XX" => "Z"})
    end
  end

  def test_initialize_missing_field_definitions
    assert_nothing_raised do
      GFA::Line.new(["H","id:i:1"], [[:record_type, /[A-Z]/]], {})
    end
    assert_raise(ArgumentError) do
      GFA::Line.new(["H","id:i:1"], nil, {"xx" => "i"})
    end
    assert_raise(ArgumentError) do
      GFA::Line.new(["H","id:i:1"], [[:record_type, /[A-Z]/]], nil)
    end
  end

  def test_initialize_duplicate_field_names
    assert_raise(ArgumentError) do
      GFA::Line.new(["H","id:i:1"],
                    [[:record_type, /[A-Z]/],
                     [:XX, /.*/],
                     [:XX, /.*/]], {"ZZ" => "i"})
    end
    assert_raise(ArgumentError) do
      GFA::Line.new(["H", "1"],
                    [[:record_type, /[A-Z]/],
                     [:XX, /.*/]], {"XX" => "i"})
    end
  end

  def test_initialize_custom_optfield
    assert_raise(GFA::Line::CustomOptfieldNameError) do
      GFA::Line.new(["H","XX:i:1"],
                    [[:record_type, /[A-Z]/]],{"XY" => "i"})
    end
    assert_raise(GFA::Line::CustomOptfieldNameError) do
      GFA::Line.new(["H","a","xx:i:1"],
                    [[:record_type, /[A-Z]/],
                     [:xx, /.*/]],
                     {"ZZ" => "i"})
    end
  end

  def test_clone
    l = "H\tVN:Z:1.0".to_gfa_line
    l1 = l
    l2 = l.clone
    assert_equal(GFA::Line::Header, l.class)
    assert_equal(GFA::Line::Header, l2.class)
    l2.VN="2.0"
    assert_equal("2.0", l2.VN)
    assert_equal("1.0", l.VN)
    l1.VN="2.0"
    assert_equal("2.0", l.VN)
  end

  def test_respond_to
    l = GFA::Line.new(["H","12","xx:i:13","XY:Z:HI"],
                      [[:record_type, /[A-Z]/],[:from, /[0-9]+/]],
                       {"XY"=>"Z"})
    assert(l.respond_to?(:record_type))
    assert(l.respond_to?(:record_type=))
    assert(l.respond_to?(:from))
    assert(l.respond_to?(:from=))
    assert(l.respond_to?(:XY))
    assert(l.respond_to?(:XY!))
    assert(l.respond_to?(:XY=))
    assert(l.respond_to?(:aa))
    assert(l.respond_to?(:aa!))
    assert(l.respond_to?(:aa=))
  end

  def test_field_getters_required_fields
    l = GFA::Line.new(["H","12","xx:i:13","XY:Z:HI"],
                      [[:record_type, /[A-Z]/],[:from, /[0-9]+/]],
                       {"XY"=>"Z"})
    assert_equal("H", l[0])
    assert_equal("H", l.get_field(0))
    assert_equal(:record_type, l.fieldnames[0])
    assert_equal(:record_type, l.required_fieldnames[0])
    assert_equal("H", l.record_type)
    assert_equal("12", l.from)
    assert_raise(NoMethodError) { l.zzz }
  end

  def test_field_getters_existing_optional_fields
    l = GFA::Line.new(["H","12","xx:i:13","XY:Z:HI"],
                      [[:record_type, /[A-Z]/],[:from, /[0-9]+/]],
                       {"XY"=>"Z"})
    assert_equal(13, l[2])
    assert_equal(13, l.get_field(2))
    assert_equal("13", l.get_field(2, false))
    assert_equal(:xx, l.fieldnames[2])
    assert_equal(:xx, l.optional_fieldnames[0])
    assert_equal(13, l.xx)
    assert_equal(13, l.xx!)
    assert_equal("13", l.xx(false))
    assert_equal("HI", l.XY)
    assert_equal("HI", l.XY!)
  end

  def test_field_getters_not_existing_optional_fields
    l = GFA::Line.new(["H","12","xx:i:13","XY:Z:HI"],
                      [[:record_type, /[A-Z]/],[:from, /[0-9]+/]],
                       {"XY"=>"Z"})
    assert_equal(nil, l.zz)
    assert_raise(RuntimeError) { l.zz! }
  end

  def test_field_setters_required_fields
    l = GFA::Line.new(["H","12","xx:i:13","XY:Z:HI"],
                      [[:record_type, /[A-Z]/],[:from, /[0-9]+/]],
                       {"XY"=>"Z"})
    l.record_type = "S"
    assert_equal("S", l.record_type)
    assert_raise(GFA::Line::RequiredFieldTypeError) { l.from = "A" }
    l.from = "14"
    assert_equal("14", l.from)
  end

  def test_field_setters_existing_optional_fields
    l = GFA::Line.new(["H","12","xx:i:13","XY:Z:HI"],
                      [[:record_type, /[A-Z]/],[:from, /[0-9]+/]],
                       {"XY"=>"Z"})
    assert_equal(13, l.xx)
    l.xx = 15
    assert_equal(15, l.xx)
    assert_raise(GFA::Optfield::ValueError) { l.xx = "1A" }
    assert_equal("HI", l.XY)
    l.XY = "HO"
    assert_equal("HO", l.XY)
  end

  def test_field_setters_not_existing_optional_fields
    l = GFA::Line.new(["H","12","xx:i:13","XY:Z:HI"],
                      [[:record_type, /[A-Z]/],[:from, /[0-9]+/]],
                       {"XY"=>"Z"})
    assert_nothing_raised { l.zz="1" }
    assert_equal("1", l.zz)
    assert_nothing_raised { l.zi=1 }
    assert_equal(1, l.zi)
    assert_nothing_raised { l.zf=1.0 }
    assert_equal(1.0, l.zf)
    assert_nothing_raised { l.bf=[1.0,1.0] }
    assert_equal([1.0,1.0], l.bf)
    assert_nothing_raised { l.bi=[1.0,1.0] }
    assert_equal([1,1], l.bi)
    assert_nothing_raised { l.bz=[1.0,1] }
    assert_equal("1.0,1", l.bz)
    assert_raise(NoMethodError) { l.zzz="1" }
  end

  def test_add_optfield
    l = GFA::Line.new(["H","12","xx:i:13"],
                      [[:record_type, /[A-Z]/],[:from, /[0-9]+/]],
                       {"XY"=>"Z"})
    assert_equal(nil, l.XY)
    l << "XY:Z:HI"
    assert_equal("HI", l.XY)
    assert_raise(GFA::Line::DuplicateOptfieldNameError) {l << "XY:Z:HI"}
  end

  def test_to_s
    fields = ["H","12","xx:i:13","XY:Z:HI"]
    l = GFA::Line.new(fields,
                      [[:record_type, /[A-Z]/],[:from, /[0-9]+/]],
                       {"XY"=>"Z"})
    assert_equal(fields.join("\t"),l.to_s)
  end

  def test_to_gfa_line
    fields = ["H","12","xx:i:13","XY:Z:HI"]
    l = GFA::Line.new(fields,
                      [[:record_type, /[A-Z]/],[:from, /[0-9]+/]],
                       {"XY"=>"Z"})
    l1 = l.to_gfa_line
    assert_equal(GFA::Line, l1.class)
    assert_equal(l, l1)
  end

  def test_other_orientation
    assert_equal("+", GFA::Line.other_orientation("-"))
    assert_equal("-", GFA::Line.other_orientation("+"))
    assert_raises(RuntimeError) {GFA::Line.other_orientation("x")}
  end

  def test_validate
    l = GFA::Line.new(["H","12","xx:i:13","XY:Z:HI"],
                      [[:record_type, /[A-Z]/],[:from, /[0-9]+/]],
                       {"XY"=>"Z"})
    assert_nothing_raised {l.validate!}
    l.record_type = "Z"
    assert_raise(GFA::Line::UnknownRecordTypeError) {l.validate!}
  end

  def test_string_to_gfa_line
    str = "H\tVN:Z:1.0"
    l = str.to_gfa_line
    assert_equal(GFA::Line::Header, l.class)
    assert_equal(GFA::Line::Header, l.to_gfa_line.class)
    assert_equal(str, l.to_gfa_line.to_s)
  end

end
