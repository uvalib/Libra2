module Libra::Theses
  module Metadata
    extend ActiveSupport::Concern

    included do

      # CustomMetadata
      property :draft, predicate: ::RDF::URI('http://example.org/terms/draft'), multiple: false do |index|
        index.as :stored_searchable
      end

    end

  end
end
