module ActionForm
  module Form
    extend ActiveSupport::Concern
    include ActiveModel::Model

    module ClassMethods

      def attribute_mapping
        @attribute_mapping ||= AttributeMapping.new
      end

      private

      def define_component_reader(name)
        if !method_defined?(name)
          define_method(name) do
            if instance_variable_defined?("@#{name}")
              return instance_variable_get("@#{name}")
            end

            klass = name.to_s.classify.constantize
            instance_variable_set("@#{name}", klass.new)
          end
        end
      end

      def define_attribute_accessor(name, from:)
        define_attribute_reader(name, from: from)
        define_attribute_writer(name, from: from)
      end

      def define_attribute_reader(name, from:)
        define_method(name) do
          send(from).send(name)
        end
      end

      def define_attribute_writer(name, from:)
        define_method("#{name}=") do |value|
          send(from).send("#{name}=", value)
        end
      end

      public

      def attribute(name, from:)
        self.attribute_mapping.add(name, from)

        define_component_reader(from)
        define_attribute_accessor(name, from: from)
      end

      def attributes(*names, from:)
        names.each {|n| attribute(n, from: from) }
      end
    end

    def valid?
      validate_associated && super
    end

    def save(&block)
      return false unless valid?
      yield
    end

    private

    def components
      self.class.attribute_mapping.map do |klass, attributes|
        klass.new.tap do |instance|
          attributes.each {|a| instance.send("#{a}=", send(a)) }
        end
      end
    end

    def validate_associated
      self.errors.clear

      components.each do |component|
        # We validate this, but it's possible we don't care about the error that
        # gets generated, we will still strip out this key
        if !component.valid?
          self.errors.merge!(component.errors)

          # Now delete the ones we don't care about
          allowed_keys = self.class.attribute_mapping.for(component.class)
          error_keys   = component.errors.keys

          (error_keys - allowed_keys).each {|k| self.errors.delete(k) }
        end
      end

      self.errors.none?
    end
  end
end
