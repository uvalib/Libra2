module CurationConcerns
  module Renderers
    class CustomPublicAttributeRenderer < AttributeRenderer

      def render
        markup = ''
        markup << %(<div class='document-row'>)
        markup << label
        markup << %(<br>)
        Array(values).each do |value|
          markup << attribute_value_to_html(value.to_s)
        end
        markup << %(</div>)
        markup.html_safe
      end

      def label
        content_tag(:span, @field, { class: "document-label" })
      end

      private

      def attribute_value_to_html(value)
          "<span class='document-value'>#{li_value(value)}</span>"
      end

      def li_value(value)
        auto_link( ERB::Util.h(value), :html => { :target => '_blank' } )
      end

    end
  end
end
