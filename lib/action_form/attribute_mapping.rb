module ActionForm
  class AttributeMapping
    include Enumerable

    delegate :each, :inspect, to: :@mapping

    def initialize
      @mapping = {}
    end

    def add(name, class_name)
      key = class_for(class_name)

      @mapping[key] ||= []
      @mapping[key] << name
    end

    def for(klass)
      @mapping[klass] || []
    end

    private

    def class_for(class_name)
      if class_name.is_a?(Symbol)
        class_name.to_s.classify.constantize
      else
        class_name.constantize
      end
    end
  end
end
