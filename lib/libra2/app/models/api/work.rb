require_dependency 'concerns/libra2/solr_extract'

module API

class Work

  include Libra2::SolrExtract

  attr_accessor :id
  attr_accessor :depositor_email

  attr_accessor :author_email
  attr_accessor :author_first_name
  attr_accessor :author_last_name
  attr_accessor :author_institution
  attr_accessor :author_department

  attr_accessor :identifier
  attr_accessor :title
  attr_accessor :abstract
  attr_accessor :create_date
  attr_accessor :modified_date
  attr_accessor :published_date

  attr_accessor :creator_email
  attr_accessor :embargo_state
  attr_accessor :embargo_end_date
  attr_accessor :notes
  attr_accessor :admin_notes

  attr_accessor :rights
  attr_accessor :advisors

  attr_accessor :keywords
  attr_accessor :language
  attr_accessor :related_links
  attr_accessor :sponsoring_agency

  attr_accessor :degree
  attr_accessor :url

  attr_accessor :status
  attr_accessor :filesets

  attr_accessor :field_set

  EMBARGO_STATE_MAP = {
     'No Embargo' => 'open',
     'UVA Only Embargo' => 'authenticated',
     'Metadata Only Embargo' => 'restricted'
  }

  def initialize

    @id = ''
    @depositor_email = ''

    @author_email = ''
    @author_first_name =  ''
    @author_last_name = ''
    @author_institution = ''
    @author_department = ''

    @identifier = ''
    @title = ''
    @abstract = ''
    @create_date = ''
    @modified_date = ''
    @published_date = ''

    @creator_email = ''
    @embargo_state = ''
    @embargo_end_date = ''
    @notes = ''
    @admin_notes = []

    @rights = ''
    @advisors = []

    @keywords = []
    @language = ''
    @related_links = []
    @sponsoring_agency = []

    @degree = ''
    @url = ''

    @status = ''
    @filesets = []

    # the set of fields specified during construction
    @field_set = []

  end

  #
  # we create these work items from JSON records when accepting a set of updates
  # we have to keep track of what was set so we can distinguish it from a default
  # value that was not specifically set
  #
  def from_json( json )

    @depositor_email = set_field( :depositor_email, json ) unless set_field( :depositor_email, json ) == nil

    @author_email = set_field( :author_email, json ) unless set_field( :author_email, json ) == nil
    @author_first_name = set_field( :author_first_name, json ) unless set_field( :author_first_name, json ) == nil
    @author_last_name = set_field( :author_last_name, json ) unless set_field( :author_last_name, json ) == nil
    @author_institution = set_field( :author_institution, json ) unless set_field( :author_institution, json ) == nil
    @author_department = set_field( :author_department, json ) unless set_field( :author_department, json ) == nil

    @title = set_field( :title, json ) unless set_field( :title, json ) == nil
    @abstract = set_field( :abstract, json ) unless set_field( :abstract, json ) == nil
    @create_date = set_field( :create_date, json ) unless set_field( :create_date, json ) == nil
    @modified_date = set_field( :modified_date, json ) unless set_field( :modified_date, json ) == nil
    @published_date = set_field( :published_date, json ) unless set_field( :published_date, json ) == nil

    @embargo_state = set_field( :embargo_state, json ) unless set_field( :embargo_state, json ) == nil
    @embargo_end_date = set_field( :embargo_end_date, json ) unless set_field( :embargo_end_date, json ) == nil

    @notes = set_field( :notes, json ) unless set_field( :notes, json ) == nil
    @admin_notes = set_field( :admin_notes, json ) unless set_field( :admin_notes, json ) == nil

    @rights = set_field( :rights, json ) unless set_field( :rights, json ) == nil
    @advisors = set_field( :advisors, json ) unless set_field( :advisors, json ) == nil

    @keywords = set_field( :keywords, json ) unless set_field( :keywords, json ) == nil
    @language = set_field( :language, json ) unless set_field( :language, json ) == nil
    @related_links = set_field( :related_links, json ) unless set_field( :related_links, json ) == nil
    @sponsoring_agency = set_field( :sponsoring_agency, json ) unless set_field( :sponsoring_agency, json ) == nil

    @degree = set_field( :degree, json ) unless set_field( :degree, json ) == nil

    @status = set_field( :status, json ) unless set_field( :status, json ) == nil

    return self
  end

  #
  # we create these work items from SOLR records when delivering results
  #
  def from_solr( solr )

    @id = solr['id'] unless solr['id'].blank?
    @depositor_email = solr_extract_first( solr, 'depositor' )

    @author_email = solr_extract_first( solr, 'author_email' )
    @author_first_name = solr_extract_first( solr, 'author_first_name' )
    @author_last_name = solr_extract_first( solr, 'author_last_name' )
    @author_institution = solr_extract_first( solr, 'author_institution' )
    @author_department = solr_extract_first( solr, 'department' )

    @identifier = solr_extract_first( solr, 'identifier' )
    @title = solr_extract_first( solr, 'title' )
    @abstract = solr_extract_first( solr, 'description' )

    @create_date = solr_extract_first( solr, 'date_created' ).gsub( '/', '-' )
    @modified_date = solr_extract_only( solr, 'date_modified', 'date_modified_dtsi' )
    @published_date = solr_extract_first( solr, 'date_published' ).gsub( '/', '-' )

    @creator_email = solr_extract_first( solr, 'creator' )
    @embargo_state = translate_embargo_name( solr_extract_first( solr, 'embargo_state' ) )
    @embargo_end_date = solr_extract_first( solr, 'embargo_end_date', 'embargo_end_date_dtsim' )

    @notes = solr_extract_first( solr, 'notes' )
    @admin_notes = solr_extract_all( solr, 'admin_notes' )

    @rights = solr_extract_first( solr, 'rights' )
    @advisors = solr_extract_all( solr, 'contributor' )

    @keywords = solr_extract_all( solr, 'keyword' )
    @language = solr_extract_first( solr, 'language' )
    @related_links = solr_extract_all( solr, 'related_url' )
    @sponsoring_agency = solr_extract_all( solr, 'sponsoring_agency' )

    @degree = solr_extract_first( solr, 'degree' )
    @url = GenericWork.doi_url( @identifier )

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

  def valid_for_update?

    # handle special cases...
    return false if field_set?( :embargo_state ) && valid_embargo_state?( @embargo_state ) == false
    return false if field_set?( :embargo_end_date ) && valid_embargo_date?( @embargo_end_date ) == false
    return false if field_set?( :status ) && ['pending','submitted'].include?( @status ) == false

    # if we specified anything else
    return @field_set.empty? == false

  end

  # was this field specifically set during construction
  def field_set?( field )
    return @field_set.include?( field )
  end

  def convert_date( date )
    begin
      return DateTime.strptime( date, '%Y-%m-%d' )
    rescue => e
      return nil
    end
  end

  # ignore the @field_set when creating JSON
  def as_json(options={})
    options[:except] ||= ['field_set']
    super( options )
  end

  def embargo_state_name
    return EMBARGO_STATE_MAP[ @embargo_state ] unless EMBARGO_STATE_MAP[ @embargo_state ].nil?
    return 'unknown'
  end

  private

  def valid_embargo_date?( date )
    return convert_date( date ) != nil
  end

  def valid_embargo_state?( state )
    return EMBARGO_STATE_MAP.keys.include? state
  end

  def translate_embargo_name( state )
    EMBARGO_STATE_MAP.keys.each do |key|
      return key if state == EMBARGO_STATE_MAP[key]
    end
    return ''
  end

  def set_field( field, json )
    if json.key?( field )
      #puts "==> #{field} was set"
      @field_set << field unless @field_set.include?( field )
      return json[field] unless json[field] == ['']
      return []
    end
    return nil
  end

end

end
