require_dependency 'concerns/libra2/solr_extract'

module API

class Work

  include Libra2::SolrExtract

  attr_accessor :id
  attr_accessor :author_email
  attr_accessor :author_first_name
  attr_accessor :author_last_name

  attr_accessor :identifier
  attr_accessor :title
  attr_accessor :abstract
  attr_accessor :create_date
  attr_accessor :modified_date

  attr_accessor :creator_email
  attr_accessor :embargo_state
  attr_accessor :embargo_end_date
  attr_accessor :notes
  attr_accessor :admin_notes

  attr_accessor :rights
  attr_accessor :advisers

  attr_accessor :keywords
  attr_accessor :language
  attr_accessor :related_links
  attr_accessor :sponsoring_agency

  attr_accessor :status
  attr_accessor :filesets

  def initialize
    @id = ''
    @author_email = ''
    @author_first_name =  ''
    @author_last_name = ''

    @identifier = ''
    @title = ''
    @abstract = ''
    @create_date = ''
    @modified_date = ''

    @creator_email = ''
    @embargo_state = ''
    @embargo_end_date = ''
    @notes = ''
    @admin_notes = []

    @rights = ''
    @advisers = []

    @keywords = []
    @language = ''
    @related_links = []
    @sponsoring_agency = []

    @status = ''
    @filesets = []
  end

  def from_json( json )

    @author_email = json[:author_email] unless json[:author_email].blank?
    @author_first_name = json[:author_first_name] unless json[:author_first_name].blank?
    @author_last_name = json[:author_last_name] unless json[:author_last_name].blank?

    @title = json[:title] unless json[:title].blank?
    @abstract = json[:abstract] unless json[:abstract].blank?

    @embargo_state = json[:embargo_state] unless json[:embargo_state].blank?
    @embargo_end_date = json[:embargo_end_date] unless json[:embargo_end_date].blank?

    @notes = json[:notes] unless json[:notes].blank?
    @admin_notes = json[:admin_notes] unless json[:admin_notes].blank?

    @rights = json[:rights] unless json[:rights].blank?
    @advisers = json[:advisers] unless json[:advisers].blank?

    @keywords = json[:keywords] unless json[:keywords].blank?
    @language = json[:language] unless json[:language].blank?
    @related_links = json[:related_links] unless json[:related_links].blank?
    @sponsoring_agency = json[:sponsoring_agency] unless json[:sponsoring_agency].blank?

    return self
  end

  def from_solr( solr )

    @id = solr['id'] unless solr['id'].blank?
    @author_email = solr_extract_first( solr, 'author_email' )
    @author_first_name = solr_extract_first( solr, 'author_first_name' )
    @author_last_name = solr_extract_first( solr, 'author_last_name' )

    @identifier = solr_extract_first( solr, 'identifier' )
    @title = solr_extract_first( solr, 'title' )
    @abstract = solr_extract_first( solr, 'description' )

    @create_date = solr_extract_first( solr, 'date_created' ).gsub( '/', '-' )
    @modified_date = solr_extract_only( solr, 'date_modified', 'date_modified_dtsi' )

    @creator_email = solr_extract_first( solr, 'creator' )
    @embargo_state = solr_extract_first( solr, 'embargo_state' )
    @embargo_end_date = solr_extract_first( solr, 'embargo_end_date', 'embargo_end_date_dtsim' )

    @notes = solr_extract_first( solr, 'notes' )
    @admin_notes = solr_extract_all( solr, 'admin_notes' )

    @rights = solr_extract_first( solr, 'rights' )
    @advisers = solr_extract_all( solr, 'contributor' )

    @keywords = solr_extract_all( solr, 'keyword' )
    @language = solr_extract_first( solr, 'language' )
    @related_links = solr_extract_all( solr, 'related_url' )
    @sponsoring_agency = solr_extract_all( solr, 'sponsoring_agency' )

    if solr_extract_first( solr, 'draft') == 'true'
       if @modified_date.blank? == false
         @status = 'in-progress'
       else
         @status = 'pending'
       end
    else
      @status = 'submitted'
    end

    @filesets = solr_extract_all( solr, 'member_ids', 'member_ids_ssim' )

    return self
  end

end

end
