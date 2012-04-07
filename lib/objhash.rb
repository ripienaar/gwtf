module ObjHash
  include Enumerable

  module ClassMethods
    # Create a new known property of the ObjHash
    # it's imagined these might have validators, defaults
    # required etc associated with them in args
    def property(name, args={:default => nil, :validation => nil})
      name = name.to_s

      raise "Already have a property #{name}" if objhash_config.include?(name)

      objhash_config[name] = {:default => nil, :validation => nil}.merge(args)
    end

    def objhash_config
      @objhash_values ||= {
                           "created_at" => {:default => lambda { Time.now }},
                           "edited_at" => {:default => lambda { Time.now }}
                          }
    end

    def objhash_default_value(property)
      property = property.to_s

      raise "Unknown property #{property}" unless objhash_config.include?(property)

      if objhash_config[property][:default].is_a?(Proc)
        objhash_config[property][:default].call
      else
        objhash_config[property][:default]
      end
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end

  def default_property_value(property)
    self.class.objhash_default_value(property)
  end

  def objhash_config
    self.class.objhash_config
  end

  def objhash_values
    return @objhash_values if @objhash_values

    @objhash_values = {}

    objhash_config.each_pair do |property, args|
      update_property(property, default_property_value(property))
    end

    @objhash_values
  end

  def include?(property)
    objhash_config.include?(property.to_s)
  end

  def update_property(property, value)
    property = property.to_s

    raise "Unknown property #{property}" unless include?(property)

    validate_property(property, value)

    objhash_values[property] = value
    objhash_values["edited_at"] = Time.now
  end

  def validate_property(property, value)
    raise "Unknown property #{property}" unless include?(property)

    validation = objhash_config[property.to_s][:validation]

    return true if validation.nil?

    # if the value is the default we dont validate it allowing nil
    # defaults but validation only on assignment of non default value
    return true if value == objhash_config[property.to_s][:default]

    raise "#{property} should be #{validation}" if value.nil? && !validation.nil?

    if validation.is_a?(Symbol)
      case validation
        when :boolean
          raise "#{property} should be a boolean" unless [TrueClass, FalseClass].include?(value.class)
        when :ipv6
          begin
            require 'ipaddr'
            ip = IPAddr.new(value)
            raise "#{property} should be a valid IPv6 address" unless ip.ipv6?
          rescue
            raise "#{property} should be a valid IPv6 address"
          end

        when :ipv4
          begin
            require 'ipaddr'
            ip = IPAddr.new(value)
            raise "#{property} should be a valid IPv4 address" unless ip.ipv4?
          rescue
            raise "#{property} should be a valid IPv4 address"
          end
        else
          raise "Don't know how to validate #{property} using #{validation}"
      end

    elsif validation.is_a?(Array)
      raise "%s should be one of %s" % [property, validation.join(", ")] unless validation.include?(value)

    elsif validation.is_a?(Regexp)
      raise "#{property} should match #{validation}" unless value.match(validation)

    elsif validation.is_a?(Proc)
      raise "#{property} does not validate against lambda" unless validation.call(value)

    else
      raise "#{property} is a #{value.class} should be a #{validation}" unless value.is_a?(validation)
    end

    return true
  end

  def to_hash
    objhash_values
  end

  def to_s
    objhash_values.inspect
  end

  def to_json
    objhash_values.to_json
  end

  def to_yaml
    objhash_values.to_yaml
  end

  def each
    objhash_values.keys.sort.each do |property|
      yield [property, objhash_values[property]]
    end
  end

  def [](property)
    raise "No such property: #{property}" unless include?(property)

    objhash_values[property.to_s]
  end

  def []=(property, value)
    update_property(property, value)
  end

  def merge(hsh)
    objhash_values.merge(hsh)
  end

  def merge!(hsh)
    raise TypeError, "Can't convert #{hsh.class} into Hash" unless hsh.respond_to?(:to_hash)

    objhash_values.keys.each do |k|
      next if ["edited_at", "created_at"].include?(k)
      update_property(k, hsh[k]) if hsh.include?(k)
    end

    self
  end

  # simple read from the class:
  #
  #   >> i.description
  #   => "Sample Item"
  #
  # method like writes:
  #
  #   >> i.description "This is a test"
  #   => "This is a test"
  #
  # assignment
  #
  #   >> i.description = "This is a test"
  #   => "This is a test"
  #
  # boolean
  #
  #   >> i.description?
  #   => false
  #   >> i.description "foo"
  #   => foo
  #   >> i.has_description?
  #   => true
  #   >> i.has_description
  #   => true
  def method_missing(method, *args)
    method = method.to_s

    if include?(method)
      if args.empty?
        return objhash_values[method]
      else
        return update_property(method, args.first)
      end

    elsif method =~ /^(has_)*(.+?)\?$/
      return !!objhash_values[$2]

    elsif method =~ /^(.+)=$/
      property = $1
      return update_property(property, args.first) if include?(property)
    end

    raise NameError, "undefined local variable or method `#{method}'"
  end
end
