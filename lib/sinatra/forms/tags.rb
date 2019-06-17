module Sinatra
  module Forms
    module Tags
      class Tag
        def initialize(tag_name, options = {})
          @tag_name = tag_name
          @options  = options
        end

        def to_s
          %{<#{@tag_name}#{formatted_options}/>}
        end

        private

        def options
          @options
        end

        def formatted_options
          output = flattened_options.map {|k,v| %{#{k}="#{v}"} }.join(" ")
          (output.length > 0) ? " #{output}" : ""
        end

        def flattened_options
          options.inject({}) do |mapping, (key, value)|
            mapping.merge(key => Array(value).join(" "))
          end
        end
      end

      class ContentTag < Tag
        def initialize(tag_name, content, options = {})
          @content = content
          super(tag_name, options)
        end

        def to_s
          %{<#{@tag_name}#{formatted_options}>#{content}</#{@tag_name}>}
        end

        private

        def content
          @content
        end
      end

      class LabelTag < ContentTag
        def initialize(value, options = {})
          raise ArgumentError, "Must supply `for:` option" unless options.key?(:for)
          super(:label, value, options)
        end
      end

      class InputTag < Tag
        def initialize(type, name, value, options = {})
          @type  = type
          @name  = name
          @value = value

          super(:input, options)
        end

        private

        def options
          options = @options.merge(type: @type, value: @value)
          {name: @name, id: @name}.merge(options)
        end
      end

      class TextInputTag < InputTag
        def initialize(name, value, options = {})
          super(:text, name, value, options)
        end
      end

      class PasswordInputTag < InputTag
        def initialize(name, options = {})
          super(:password, name, nil, options)
        end
      end

      class SelectTag < ContentTag
        def initialize(name, choices, selected_value, options = {})
          @name           = name
          @choices        = choices
          @selected_value = selected_value

          super(:select, nil, options)
        end

        private

        def options
          {name: @name, id: @name}.merge(@options)
        end

        def content
          ([blank_option_tag] + option_tags).map(&:to_s).join("\n")
        end

        def blank_option_tag
          Tags::OptionTag.new("", "Choose", "")
        end

        def option_tags
          @option_tags ||= @choices.map do |choice|
            Tags::OptionTag.new(choice[1], choice[0], @selected_value)
          end
        end
      end

      class OptionTag < ContentTag
        def initialize(value, label, selected_value)
          @value          = value
          @selected_value = selected_value

          super(:option, label)
        end

        private

        def selected?
          @value.to_s == @selected_value.to_s
        end

        def options
          options = {value: @value}
          options.merge!(selected: "selected") if selected?
          options
        end
      end
    end
  end
end
