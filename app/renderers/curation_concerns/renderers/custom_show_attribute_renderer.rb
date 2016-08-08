module CurationConcerns
  module Renderers
    class CustomShowAttributeRenderer < AttributeRenderer

      private

      def li_value(value)
        auto_link( ERB::Util.h(value), :html => { :target => '_blank' } )
      end

    end
  end
end
