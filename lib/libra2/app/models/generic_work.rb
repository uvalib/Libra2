# Generated via
#  `rails generate curation_concerns:work GenericWork`
class GenericWork < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::CurationConcerns::BasicMetadata
  include Sufia::WorkBehavior
  validates :title, presence: { message: 'Your work must have a title.' }

  # work type definitions
  WORK_TYPE_GENERIC = 'generic_work'.freeze
  WORK_TYPE_THESIS = 'thesis'.freeze

  # Custom Metadata
  #
  # work_type - Currently either a 'thesis' or a 'generic_work'.
  property :work_type, predicate: ::RDF::URI('http://example.org/terms/work_type'), multiple: false do |index|
    index.as :stored_searchable
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


end
