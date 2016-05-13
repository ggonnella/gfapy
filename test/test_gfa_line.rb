require_relative "../lib/gfa.rb"
require "test/unit"

class TestGFALine < Test::Unit::TestCase

  def test_basic
    l = GFA::Line.new(["H"],[[:record_type, /H/]],{})
    assert(l)
  end

  def test_unknown_record_type
    assert_raise(GFA::Line::UnknownRecordTypeError) do
      GFA::Line.new(["A"],[[:record_type, /[A-Z]/]],{})
    end
  end

  def test_not_enough_required
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

  def test_too_many_required
    assert_raise(TypeError) do
      GFA::Line.new(["H","1","2"],
                    [[:record_type, /[A-Z]/],[:from, /[0-9]+/]],{})
    end
  end

  def test_predefined_optfield_wrong_type
    assert_nothing_raised do
      GFA::Line.new(["H","XX:Z:A"],[[:record_type, /[A-Z]/]],{"XX" => "Z"})
    end
    assert_raise(GFA::Line::PredefinedOptfieldTypeError) do
      GFA::Line.new(["H","XX:i:1"],[[:record_type, /[A-Z]/]],{"XX" => "Z"})
    end
  end

  def test_wrong_optfield_format
    assert_raise(TypeError) do
      GFA::Line.new(["H","XX Z-A"],
                    [[:record_type, /[A-Z]/]],{"XX" => "Z"})
    end
  end

  def test_reqfield_invalid_name
    assert_raise(GFA::Line::InvalidFieldNameError) do
      GFA::Line.new(["H","1"],[[:record_type, /[A-Z]/],[:to_s, /[0-9]+/]],{})
    end
  end

  def test_reqfield_type_error
    assert_raise(GFA::Line::RequiredFieldTypeError) do
      GFA::Line.new(["H","A"],[[:record_type, /[A-Z]/],[:from, /[0-9]+/]],{})
    end
  end

  def test_optfield_type_error
    assert_raise(GFA::Optfield::ValueError) do
      GFA::Line.new(["H","ZZ:i:12A"],
                    [[:record_type, /[A-Z]/]],{"ZZ" => "i"})
    end
  end

  def test_duplicate_optfield
    assert_raise(GFA::Line::DuplicateOptfieldNameError) do
      GFA::Line.new(["H","XX:i:1", "XX:i:2"],
                    [[:record_type, /[A-Z]/]],{"XX" => "i"})
    end
    assert_raise(GFA::Line::DuplicateOptfieldNameError) do
      GFA::Line.new(["H","zz:i:1", "XX:Z:A", "zz:i:2"],
                    [[:record_type, /[A-Z]/]],{"XX" => "Z"})
    end
  end

  def test_missing_field_definitions
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

  def test_duplicate_field_names
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

  def test_custom_optfield
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

  def test_field_getters
    l = GFA::Line.new(["H","12","xx:i:13","XY:Z:HI"],
                      [[:record_type, /[A-Z]/],[:from, /[0-9]+/]],
                       {"XY"=>"Z"})

    assert_equal("H", l.record_type)
    assert_equal("12", l.from)
    assert_equal("13", l.xx)
    assert_equal("HI", l.XY)
    assert_raise(NoMethodError) { l.ZZ }
  end

  def test_field_setters
    l = GFA::Line.new(["H","12","xx:i:13","XY:Z:HI"],
                      [[:record_type, /[A-Z]/],[:from, /[0-9]+/]],
                       {"XY"=>"Z"})
    assert_equal("H", l.record_type)
    l.record_type = "S"
    assert_equal("S", l.record_type)
    assert_equal("12", l.from)
    assert_raise(GFA::Line::RequiredFieldTypeError) { l.from = "A" }
    l.from = "14"
    assert_equal("14", l.from)
    assert_equal("13", l.xx)
    l.xx = "15"
    assert_equal("15", l.xx)
    assert_raise(GFA::Optfield::ValueError) { l.xx = "1A" }
    assert_equal("HI", l.XY)
    l.XY = "HO"
    assert_equal("HO", l.XY)
    assert_raise(NoMethodError) { l.ZZ="1" }
  end

end
