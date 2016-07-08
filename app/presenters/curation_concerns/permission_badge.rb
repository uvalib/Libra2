module CurationConcerns
  class PermissionBadge
    include ActionView::Helpers::TagHelper

    def initialize(solr_document)
      @solr_document = solr_document
    end

    # Draws a span tag with styles for a bootstrap label
    def render
      content_tag(:span, link_title, title: link_title, class: "label #{dom_label_class}")
    end

    private

      def dom_label_class
        if @solr_document.is_draft?
          return 'label-danger'
        elsif @solr_document.embargo_state == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
          return 'label-info'
        elsif @solr_document.embargo_state == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
          return 'label-warning'
        else
          return 'label-success'
        end
      end

      def link_title
        if @solr_document.is_draft?
          return "Draft"
        elsif @solr_document.embargo_state == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
          return "Restricted to Abstract View Only"
        elsif @solr_document.embargo_state == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
          return "Restricted to UVA Only"
        else
          return "Visible Worldwide"
        end
      end

    #
    # TODO - DPG
    # not sure if the rest of this is in-sync with our hacked use of embargo
    #

      def open_access_with_embargo?
        return embargo?
      end

      def open_access?
        name = Solrizer.solr_name(:embargo_state, :stored_searchable)
        @open_access = @solr_document[name] == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC if @open_access.nil?
        @open_access
      end

      def registered?
        name = Solrizer.solr_name(:embargo_state, :stored_searchable)
        @registered = @solr_document[name] == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED if @registered.nil?
        @registered
      end

      def embargo?
        name = Solrizer.solr_name(:embargo_state, :stored_searchable)
        state = @solr_document[name]
        return false if state.nil?
        state = state.join("") if state.kind_of?(Array)
        return state == "embargo"
      end
  end
end
