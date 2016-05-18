require_dependency 'concerns/libra2/basic_metadata'
require_dependency 'libra2/app/indexers/libra2_indexer'

class GenericWork < ActiveFedora::Base

  include ::CurationConcerns::WorkBehavior
  include Libra2::BasicMetadata
  include Sufia::WorkBehavior

  self.human_readable_type = 'Generic Work'

  # validations required for model integrity
  validates :title, presence: { message: 'Your work must have a title.' }
  validates :creator, presence: { message: 'Your work must have an author.' }
  validates :contributor, presence: { message: 'Your work must have a contributor.' }
  validates :description, presence: { message: 'Your work must have a description.' }
  validates :publisher, presence: { message: 'Your work must have a publisher.' }
  #validates :date_created, presence: { message: 'Your work must have a creation date.' }
  validates :rights, presence: { message: 'Your work must have a rights assignment.' }
  validates :identifier, presence: { message: 'Your work must have an identifier.' }
  validates :department, presence: { message: 'Your work must have a department.' }
  validates :degree, presence: { message: 'Your work must have a degree.' }
  validates :license, presence: { message: 'Your work must have a license acceptance.' }

  # work type definitions
  WORK_TYPE_GENERIC = 'generic_work'.freeze
  WORK_TYPE_THESIS = 'thesis'.freeze

  # defaults
  DEFAULT_PUBLISHER = 'University Of Virginia'.freeze
  DEFAULT_LICENSE = 'None'.freeze

  # embargo periods
  EMBARGO_VALUE_6_MONTH = '6_month'.freeze
  EMBARGO_VALUE_1_YEAR = '1_year'.freeze
  EMBARGO_VALUE_2_YEAR = '2_year'.freeze
  EMBARGO_VALUE_5_YEAR = '5_year'.freeze

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

  # notes associated with the deposit
  property :notes, predicate: ::RDF::URI('http://example.org/terms/notes'), multiple: false do |index|
    index.type :text
    index.as :stored_searchable
  end

  # the license assigned to the work
  property :license, predicate: ::RDF::URI('http://example.org/terms/license'), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  # sponsoring agency (grant funded work, etc)
  property :sponsoring_agency, predicate: ::RDF::URI('http://example.org/terms/sponsoring_agency') do |index|
    index.as :stored_searchable, :facetable
  end

  # notes for the administrator; not visible to normal users
  property :admin_notes, predicate: ::RDF::URI('http://example.org/terms/admin_notes') do |index|
    index.type :text
    index.as :stored_searchable
  end

  # the license assigned to the work
  property :embargo_period, predicate: ::RDF::URI('http://example.org/terms/embargo_period'), multiple: false do |index|
    index.as :stored_searchable
  end

  # specify the indexer used to create the SOLR document
  def self.indexer
    ::Libra2Indexer
  end

  # determine which fields can have multiple values...
  def self.multiple?( term )
    #puts "=====> GenericWork.multiple? #{term}"
    return true if [:keyword, :title, :contributor, :subject, :related_url, :sponsoring_agency, :admin_notes].include? term
    false
  end

  # which fields are required...
  def self.required?(term)
    #puts "=====> GenericWork.required? #{term}"
    return true if [:title, :creator, :contributor, :description, :publisher, :rights, :identifier, :department, :degree, :license].include? term
    false
  end

  # which fields are readonly...
  def self.readonly?(term)
    #puts "=====> GenericWork.readonly? #{term}"
    return true if [:date_created, :identifier, :publisher, :department, :degree, :license].include? term
    false
  end

  # have we already accepted the license agreement?
  def self.accepted_agreement?( license )
    return license != DEFAULT_LICENSE
  end
end

#
# end of file
#
