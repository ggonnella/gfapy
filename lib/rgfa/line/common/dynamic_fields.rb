module RGFA::Line::Common::DynamicFields

  # Methods are dynamically created for non-existing but valid tag names.
  # Methods for predefined tags and positional fields
  # are created dynamically for each subclass; methods for existing tags
  # are created on instance initialization.
  #
  # ---
  #  - (Object) <fieldname>(parse=true)
  # The parsed content of a field. See also #get.
  #
  # <b>Parameters:</b>
  #
  # <b>Returns:</b>
  # - (String, Hash, Array, Integer, Float) the parsed content of the field
  # - (nil) if the field does not exist, but is a valid tag field name
  #
  # ---
  #  - (Object) <fieldname>!(parse=true)
  # The parsed content of a field, raising an exception if not available.
  # See also #get!.
  #
  # <b>Returns:</b>
  # - (String, Hash, Array, Integer, Float) the parsed content of the field
  #
  # <b>Raises:</b>
  # - (RGFA::NotFoundError) if the field does not exist
  #
  # ---
  #
  #  - (self) <fieldname>=(value)
  # Sets the value of a positional field or tag,
  # or creates a new tag if the fieldname is
  # non-existing but a valid tag name. See also #set, #set_datatype.
  #
  # <b>Parameters:</b>
  # - +*value*+ (String|Hash|Array|Integer|Float) value to set
  #
  # ---
  #
  def method_missing(m, *args, &block)
    super if virtual?
    field_name, operation, state = split_method_name(m)
    if ((operation == :get or operation == :get!) and args.size > 1) or
       (operation == :set and args.size != 1)
      raise RGFA::ArgumentError, "Wrong number of arguments \n"+
        "(method: #{m}; args.size = #{args.size})"
    end
    case state
    when :invalid
      super
    when :existing
      case operation
      when :get
        if args[0] == false
          field_to_s(field_name)
        else
          get(field_name)
        end
      when :get!
        if args[0] == false
          field_to_s!(field_name)
        else
          get!(field_name)
        end
      when :set
        set_existing_field(field_name, args[0])
        return nil
      end
    when :valid
      case operation
      when :get
        return nil
      when :get!
        raise RGFA::NotFoundError,
          "No value defined for tag #{field_name}"
      when :set
        set(field_name, args[0])
        return nil
      end
    end
  end

  # Redefines respond_to? to correctly handle dynamical methods.
  # @see #method_missing
  def respond_to?(m, include_all=false)
    super || (split_method_name(m)[2] != :invalid)
  end

  private

  def split_method_name(m)
    if @data.has_key?(m)
      return m, :get, :existing
    else
      case m[-1]
      when "!"
        var = :get!
        m = m[0..-2].to_sym
      when "="
        var = :set
        m = m[0..-2].to_sym
      else
        var = :get
      end
      if @data.has_key?(m)
        state = :existing
      elsif self.class::PREDEFINED_TAGS.include?(m) or
          valid_custom_tagname?(m)
        state = :valid
      else
        state = :invalid
      end
      return m, var, state
    end
  end

  #
  # Define field methods for a single field
  #
  def define_field_methods(fieldname)
    define_singleton_method(fieldname) do
      get(fieldname)
    end
    define_singleton_method :"#{fieldname}!" do
      get!(fieldname)
    end
    define_singleton_method :"#{fieldname}=" do |value|
      set_existing_field(fieldname, value)
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
    base.instance_eval do
      private_class_method :apply_definitions
      private_class_method :define_field_accessors
      private_class_method :define_field_aliases
      private_class_method :define_reference_getters
    end
  end

  module ClassMethods

    def apply_definitions
      define_field_accessors
      define_field_aliases
      define_reference_getters
    end

    def define_field_accessors
      (self::POSFIELDS +
       self::PREDEFINED_TAGS).each do |fieldname|
        define_method(fieldname) do
          get(fieldname)
        end
        define_method :"#{fieldname}!" do
          get!(fieldname)
        end
        define_method :"#{fieldname}=" do |value|
          set_existing_field(fieldname, value)
        end
      end
    end
    def define_field_aliases
      if !self::NAME_FIELD.nil? and !self::POSFIELDS.include?(:name)
        self::FIELD_ALIAS[:name] = self::NAME_FIELD
      end
      self::FIELD_ALIAS.each do |k,v|
        alias_method :"#{k}",  :"#{v}"
        alias_method :"#{k}!", :"#{v}!"
        alias_method :"#{k}=", :"#{v}="
      end
    end

    def define_reference_getters
      (self::DEPENDENT_LINES + self::OTHER_REFERENCES).each do |k|
        if !method_defined?(k)
          define_method(k) do
            @refs ||= {}
            @refs.fetch(k, []).clone.freeze
          end
        end
      end
      if !method_defined?(:all_references)
        define_method :all_references do
          refs.values.flatten
        end
      end
    end
  end

end
