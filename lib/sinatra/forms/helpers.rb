module Sinatra
  module Forms
    module TagHelper
      def tag(tag_name, options = {})
        Tags::Tag.new(tag_name, options).to_s
      end

      def content_tag(tag_name, content, options = {})
        Tags::ContentTag.new(tag_name, content, options).to_s
      end
    end

    module FormHelper
      def form_for(object, path, method: :post, &block)
        form_tag = Forms::Form.new(object, path, method: method)
        builder  = -> { yield(form_tag) }

        buffer << form_tag.to_s { erb(capture(buffer, &builder)) }
      end

      private

      def buffer
        @_out_buf
      end

      def capture(buffer)
        pos = buffer.size
        yield
        buffer.slice!(pos..buffer.size)
      end
    end
  end
end
