require 'concerns/basic_metadata'

class GenericWork < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::Libra2::BasicMetadata
  include Sufia::WorkBehavior

  validates :title, presence: { message: 'Your work must have a title.' }

  # work type definitions
  WORK_TYPE_GENERIC = 'generic_work'.freeze
  WORK_TYPE_THESIS = 'thesis'.freeze

  # Custom Metadata

  # work_type - Currently either a 'thesis' or a 'generic_work'.
  property :work_type, predicate: ::RDF::URI('http://example.org/terms/work_type'), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  # draft - Pertinent only for 'thesis' work_type.
  #   True if the thesis is not finalized (i.e. submitted, for whatever the
  #      term means for the work resource type, (dissertation, masters,
  #      fourth_year, class, project, etc.)).
  #   False if the thesis is finalized.
  #   False for any other work_type other than 'thesis'.
  property :draft, predicate: ::RDF::URI('http://example.org/terms/draft'), multiple: false do |index|
    index.as :stored_searchable
  end

  # the institution name of the author; always UVa for thesis
  property :author_institution, predicate: ::RDF::URI('http://example.org/terms/institution'), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  # which school/department (from SIS or the deposit registration process)
  property :department, predicate: ::RDF::URI('http://example.org/terms/department'), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  # which degree (from SIS or the deposit registration process)
  property :degree, predicate: ::RDF::URI('http://example.org/terms/degree'), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  #
  property :notes, predicate: ::RDF::URI('http://example.org/terms/notes'), multiple: false do |index|
    index.type :text
    index.as :stored_searchable
  end

  #
  property :license, predicate: ::RDF::URI('http://example.org/terms/license') do |index|
    index.as :stored_searchable, :facetable
  end

  #
  property :sponsoring_agency, predicate: ::RDF::URI('http://example.org/terms/sponsoring_agency'), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  #
  property :admin_notes, predicate: ::RDF::URI('http://example.org/terms/admin_notes') do |index|
    index.type :text
    index.as :stored_searchable
  end

  class << self

    # determine which fields can have multiple values...
    def multiple?( term )
      case term.to_s
        when 'title', 'contributor', 'subject', 'related_url', 'admin_notes'
          true
        else
          false
      end
    end

  end
end
