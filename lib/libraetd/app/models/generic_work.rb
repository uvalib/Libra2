require_dependency 'concerns/libraetd/basic_metadata'
require_dependency 'libraetd/app/indexers/libra2_indexer'

require_dependency 'libraetd/app/helpers/ordered_string_helper'
include OrderedStringHelper
include UrlHelper

class GenericWork < ActiveFedora::Base

  include ::CurationConcerns::WorkBehavior
  include Libra2::BasicMetadata
  include Sufia::WorkBehavior

  self.human_readable_type = 'Generic Work'

  # validations required for model integrity
  # validates :title, presence: { message: 'Your work must have a title.' }
  #
  # validates :creator, presence: { message: 'Your work must have an author.' }
  # validates :author_email, presence: { message: 'Your work must have an author email address.' }
  # validates :author_first_name, presence: { message: 'Your work must have an author first name.' }
  # validates :author_last_name, presence: { message: 'Your work must have an author last name.' }
  # validates :author_institution, presence: { message: 'Your work must have an author institution.' }
  #
  # validates :contributor, presence: { message: 'Your work must have a contributor.' }
  # validates :description, presence: { message: 'Your work must have a description.' }
  # validates :publisher, presence: { message: 'Your work must have a publisher.' }
  # #validates :date_created, presence: { message: 'Your work must have a creation date.' }
  # validates :rights, presence: { message: 'Your work must have a rights assignment.' }
  # validates :identifier, presence: { message: 'Your work must have an identifier.' }
  # validates :department, presence: { message: 'Your work must have a department.' }
  # validates :degree, presence: { message: 'Your work must have a degree.' }
  # validates :license, presence: { message: 'Your work must have a license acceptance.' }

  # work type definitions
  WORK_TYPE_GENERIC = 'generic_work'.freeze
  WORK_TYPE_THESIS = 'thesis'.freeze

  # source definitions
  THESIS_SOURCE_SIS = 'sis'.freeze
  THESIS_SOURCE_OPTIONAL = 'optional'.freeze
  THESIS_SOURCE_LEGACY = 'libra-oa'.freeze
  THESIS_SOURCE_INGEST = 'ingest'.freeze

  # defaults
  DEFAULT_INSTITUTION = 'University of Virginia'.freeze
  DEFAULT_PUBLISHER = DEFAULT_INSTITUTION
  DEFAULT_LICENSE = 'None'.freeze
  DEFAULT_LANGUAGE = 'English'.freeze

  # embargo periods
  EMBARGO_VALUE_6_MONTH = '6_month'.freeze
  EMBARGO_VALUE_1_YEAR = '1_year'.freeze
  EMBARGO_VALUE_2_YEAR = '2_year'.freeze
  EMBARGO_VALUE_5_YEAR = '5_year'.freeze
  EMBARGO_VALUE_FOREVER = 'forever'.freeze

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

  # work_source - used to identify SIS verses optional thesis
  property :work_source, predicate: ::RDF::URI('http://example.org/terms/work_source'), multiple: false do |index|
    index.as :stored_searchable
  end

  # specific attributes for the author
  # we should probably use nested fields at some point

  # the email of the author
  property :author_email, predicate: ::RDF::URI('http://example.org/terms/email'), multiple: false do |index|
    index.as :stored_searchable
  end

  # the first name of the author
  property :author_first_name, predicate: ::RDF::Vocab::FOAF.firstName, multiple: false do |index|
    index.as :stored_searchable
  end

  # the last name of the author
  property :author_last_name, predicate: ::RDF::Vocab::FOAF.lastName, multiple: false do |index|
    index.as :stored_searchable
  end

  # the institution name of the author; always UVA for thesis
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

  # the license assigned to the work
  property :embargo_state, predicate: ::RDF::URI('http://example.org/terms/embargo_state'), multiple: false do |index|
    index.as :stored_searchable
  end

  # the license assigned to the work
  property :embargo_end_date, predicate: ::RDF::URI('http://example.org/terms/embargo_end_date'), multiple: false do |index|
    index.as :stored_searchable
  end

  # the permanent URL assigned to the work
  property :permanent_url, predicate: ::RDF::URI('http://example.org/terms/permanent_url'), multiple: false

  # the last name of the author
  property :registrar_computing_id, predicate: ::RDF::URI('http://example.org/terms/registrar_computing_id'), multiple: false

  # the id that sis attached to this thesis
  property :sis_id, predicate: ::RDF::URI('http://example.org/terms/sis_id'), multiple: false

  # the entire line that was passed when this thesis was created
  property :sis_entry, predicate: ::RDF::URI('http://example.org/terms/sis_entry'), multiple: false

  property :date_published, predicate: ::RDF::Vocab::DC.issued, multiple: false do |index|
    #property :date_created, predicate: ::RDF::Vocab::DC.created do |index|
    index.as :stored_searchable
  end

  # specify the indexer used to create the SOLR document
  def self.indexer
    ::Libra2Indexer
  end

  #
  # we want to handle the keyword list as an ordered set
  #
  def keyword
    return OrderedStringHelper.deserialize(super )
  end

  def keyword= values
    super OrderedStringHelper.serialize(values )
  end

  #
  # we want to handle the related_url list as an ordered set
  #
  def related_url
    return OrderedStringHelper.deserialize(super )
  end

  def related_url= values
    super OrderedStringHelper.serialize(values )
  end

  #
  # we want to handle the sponsoring_agency list as an ordered set
  #
  def sponsoring_agency
    return OrderedStringHelper.deserialize(super )
  end

  def sponsoring_agency= values
    super OrderedStringHelper.serialize(values )
  end

  # determine which fields can have multiple values...
  def term_multiple?( term )
    #puts "=====> GenericWork.term_multiple? #{term}"
    return true if [:keyword, :title, :contributor, :subject, :related_url, :sponsoring_agency, :admin_notes].include? term
    false
  end

  # which fields are required...
  def term_required?( term )
    #puts "=====> GenericWork.term_required? #{term}"
    return true if [:author_email, :author_first_name, :author_last_name, :author_institution, :title, :creator, :contributor, :description, :publisher, :rights, :identifier, :department, :degree, :license].include? term
    false
  end

  # which fields are readonly...
  def term_readonly?( term )
    #puts "=====> GenericWork.term_readonly? #{term}"
    return true if [:author_email, :author_institution, :date_created, :identifier, :publisher, :department, :degree, :license].include? term
    return true if term == :title && is_sis_thesis?
    false
  end

  # have we already accepted the license agreement?
  def accepted_agreement?
    return license != DEFAULT_LICENSE
  end

  def is_draft?
    return false if draft.nil?
    return draft == 'true'
  end

  def is_sis_thesis?
    return GenericWork.sis_thesis?( work_source )
  end

  def is_optional_thesis?
    return GenericWork.optional_thesis?( work_source )
  end

  def is_legacy_thesis?
    return GenericWork.legacy_thesis?( work_source )
  end

  def is_ingested_thesis?
    return GenericWork.ingested_thesis?( work_source )
  end

  def sis_authorization_id
    return work_source.split( ':' )[ 1 ] if is_sis_thesis?
    return nil
  end

  def is_mine?( me )
    return false if depositor.nil?
    #puts "===> GenericWork: depositor [#{depositor}] me [#{me}]"
    return depositor == me
  end

  def self.doi_url( doi )
    return '' if doi.nil?
    return "https://doi.org/#{doi.gsub('doi:', '')}"
  end

  def self.sis_thesis?( source )
    return false if source.nil?
    return source.start_with? GenericWork::THESIS_SOURCE_SIS
  end

  def self.optional_thesis?( source )
    return false if source.nil?
    return source.start_with? GenericWork::THESIS_SOURCE_OPTIONAL
  end

  def self.legacy_thesis?( source )
    return false if source.nil?
    return source.start_with? GenericWork::THESIS_SOURCE_LEGACY
  end

  def self.ingested_thesis?( source )
    return false if source.nil?
    return source.start_with? GenericWork::THESIS_SOURCE_INGEST
  end

  def self.displayable_embargo_period( embargo_period )
    case embargo_period
    when GenericWork::EMBARGO_VALUE_6_MONTH
      return "6 months"
    when GenericWork::EMBARGO_VALUE_1_YEAR
      return "1 year"
    when GenericWork::EMBARGO_VALUE_2_YEAR
      return "2 years"
    when GenericWork::EMBARGO_VALUE_5_YEAR
      return "5 years"
    when GenericWork::EMBARGO_VALUE_FOREVER
      return "forever"
    end
    raise "Unknown embargo period."
  end

  def self.calculate_embargo_release_date( embargo_period )
    case embargo_period
    when GenericWork::EMBARGO_VALUE_6_MONTH
      return Time.now( ) + 6.months
    when GenericWork::EMBARGO_VALUE_1_YEAR
      return Time.now( ) + 1.year
    when GenericWork::EMBARGO_VALUE_2_YEAR
      return Time.now( ) + 2.years
    when GenericWork::EMBARGO_VALUE_5_YEAR
      return Time.now( ) + 5.years
    when GenericWork::EMBARGO_VALUE_FOREVER
      return Time.now( ) + 130.years
    end
    raise "Unknown embargo period."
  end

  #
  # Thumbnail url for solr
  #
  def thumbnail_url
    # Just show defaults for now
    ActionController::Base.helpers.image_url 'default.png', host: public_site_url

    # Actual thumbnails are ready to go below.
    #if self.thumbnail.present?
    #  Rails.application.routes.url_helpers.download_url(self.thumbnail.id, file: 'thumbnail')
    #else
    #  ActionController::Base.helpers.image_url 'default.png'
    #end
  end

end

#
# end of file
#
