module Sinatra
  module Forms
    module Forms
      class ErrorMessage
        def initialize(messages, options = {})
          @messages = Array(messages)
          @options  = options
        end

        def to_s
          message ? Tags::ContentTag.new(:div, message, @options).to_s : ""
        end

        private

        def message
          @messages.join(", ") if @messages.any?
        end
      end

      module LabeledField
        def initialize(errors, input_tag_options = [])
          @errors            = errors
          @input_tag_options = input_tag_options
        end

        def to_s
          label_tag.to_s + input_tag.to_s + error_message.to_s
        end

        private

        def input_tag_options
          @input_tag_options[:class] = Array(@input_tag_options[:class])
          @input_tag_options[:class] << "is-invalid" if @errors.any?
          @input_tag_options
        end

        def humanize(text)
          text.split("_").map(&:capitalize).join(" ")
        end

        def label_text
          @input_tag_options.delete(:label) || humanize(@name.to_s)
        end

        def label_tag
          @label_tag ||= Tags::LabelTag.new(label_text, for: @name)
        end

        def input_tag
          raise ArgumentError, "you must implement `input_tag`"
        end

        def error_message
          @error_message ||= ErrorMessage.new(@errors, class: "invalid-feedback")
        end
      end

      class PasswordFieldTag
        include LabeledField

        def initialize(name, errors, input_tag_options = {})
          @name = name

          super(errors, input_tag_options)
        end

        private

        def input_tag
          @input_tag ||= Tags::PasswordInputTag.new(@name, input_tag_options)
        end
      end

      class TextFieldTag
        include LabeledField

        def initialize(name, value, errors, input_tag_options = {})
          @name  = name
          @value = value

          super(errors, input_tag_options)
        end

        private

        def input_tag
          @input_tag ||= Tags::TextInputTag.new(@name, @value, input_tag_options)
        end
      end

      class SelectFieldTag
        include LabeledField

        def initialize(name, choices, selected_value, errors, input_tag_options = {})
          @name           = name
          @choices        = choices
          @selected_value = selected_value

          super(errors, input_tag_options)
        end

        private

        def input_tag
          @input_tag ||= Tags::SelectTag.new(@name, @choices, @selected_values, input_tag_options)
        end
      end

      class Form
        def initialize(object, action, method: :post)
          @object = object
          @action = action
          @method = method
        end

        def submit(value = "Submit")
          Tags::Tag.new(:input, type: "submit", value: value)
        end

        def text_field(name, options = {})
          TextFieldTag.new( name, @object.send(name), @object.errors[name], options)
        end

        def password_field(name, options = {})
          PasswordFieldTag.new(name, @object.errors[name], options)
        end

        def select(name, choices, options = {})
          SelectFieldTag.new(name, choices, @object.send(name), @object.errors[name], options)
        end

        def to_s(&block)
          Tags::ContentTag.new(:form, yield, action: @action, method: @method).to_s
        end
      end
    end
  end
end
