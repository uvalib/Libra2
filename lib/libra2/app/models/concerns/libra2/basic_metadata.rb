module Libra2

  module BasicMetadata

    extend ActiveSupport::Concern

    included do

      property :label, predicate: ActiveFedora::RDF::Fcrepo::Model.downloadFilename, multiple: false

      property :relative_path, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#relativePath'), multiple: false

      property :import_url, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#importUrl'), multiple: false do |index|
        index.as :symbol
      end

      property :part_of, predicate: ::RDF::Vocab::DC.isPartOf

      property :resource_type, predicate: ::RDF::Vocab::DC.type, multiple: false do |index|
        #property :resource_type, predicate: ::RDF::Vocab::DC.type do |index|
        index.as :stored_searchable, :facetable
      end

      property :creator, predicate: ::RDF::Vocab::DC11.creator, multiple: false do |index|
        #property :creator, predicate: ::RDF::Vocab::DC11.creator do |index|
        index.as :stored_searchable, :facetable
      end

      #property :contributor, predicate: ::RDF::Vocab::DC11.contributor do |index|
      #  index.as :stored_searchable, :facetable
      #end

      property :description, predicate: ::RDF::Vocab::DC11.description, multiple: false do |index|
      #property :description, predicate: ::RDF::Vocab::DC11.description do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :keyword, predicate: ::RDF::Vocab::DC11.relation do |index|
        index.as :stored_searchable, :facetable
      end

      property :rights, predicate: ::RDF::Vocab::DC.rights do |index|
        index.as :stored_searchable
      end

      property :publisher, predicate: ::RDF::Vocab::DC11.publisher, multiple: false do |index|
      #property :publisher, predicate: ::RDF::Vocab::DC11.publisher do |index|
        index.as :stored_searchable, :facetable
      end

      property :date_created, predicate: ::RDF::Vocab::DC.created, multiple: false do |index|
      #property :date_created, predicate: ::RDF::Vocab::DC.created do |index|
        index.as :stored_searchable
      end

      property :subject, predicate: ::RDF::Vocab::DC11.subject do |index|
        index.as :stored_searchable, :facetable
      end

      property :language, predicate: ::RDF::Vocab::DC11.language, multiple: false do |index|
      #property :language, predicate: ::RDF::Vocab::DC11.language do |index|
        index.as :stored_searchable, :facetable
      end

      property :identifier, predicate: ::RDF::Vocab::DC.identifier, multiple: false do |index|
        index.as :stored_searchable
      end

      property :based_near, predicate: ::RDF::Vocab::FOAF.based_near do |index|
        index.as :stored_searchable, :facetable
      end

      property :related_url, predicate: ::RDF::RDFS.seeAlso do |index|
        index.as :stored_searchable
      end

      property :bibliographic_citation, predicate: ::RDF::Vocab::DC.bibliographicCitation do |index|
        index.as :stored_searchable
      end

      property :source, predicate: ::RDF::Vocab::DC.source do |index|
        index.as :stored_searchable
      end
    end
  end
end
