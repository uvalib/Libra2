require_dependency 'concerns/libraetd/solr_extract'

module API

class Work

  include Libra2::SolrExtract
  include ServiceHelper

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
  attr_accessor :embargo_period

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

  attr_accessor :source

  NO_EMBARGO_STATE = 'No Embargo'.freeze

  EMBARGO_STATE_MAP = {
     NO_EMBARGO_STATE => 'open',
     'UVA Only Embargo' => 'authenticated',
     'Metadata Only Embargo' => 'restricted'
  }

  PENDING_STATUS = 'pending'.freeze
  SUBMITTED_STATUS = 'submitted'.freeze
  INPROGRESS_STATUS = 'in-progress'.freeze

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
    @embargo_period = ''

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

    @source = ''

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

    @create_date = date_formatter solr_extract_only( solr, 'create_date', 'system_create_dtsi' )
    @modified_date = date_formatter solr_extract_only( solr, 'date_modified', 'date_modified_dtsi' )
    @published_date = date_formatter solr_extract_first( solr, 'date_published' )

    @creator_email = solr_extract_first( solr, 'creator' )
    @embargo_state = translate_embargo_name( solr_extract_first( solr, 'embargo_state' ) )
    if @embargo_state != NO_EMBARGO_STATE
      @embargo_end_date = solr_extract_first( solr, 'embargo_end_date', 'embargo_end_date_dtsim' )
      @embargo_period = solr_extract_first( solr, 'embargo_period' )
    end

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
         @status = INPROGRESS_STATUS
       else
         @status = PENDING_STATUS
       end
    else
      @status = SUBMITTED_STATUS
    end

    @filesets = solr_extract_all( solr, 'member_ids', 'member_ids_ssim' )

    work_source = solr_extract_first( solr, 'work_source' )
    @source = work_source unless work_source.blank?

    return self
  end

  def valid_for_update?

    # handle special cases...
    return false if field_set?( :embargo_state ) && valid_embargo_state?( @embargo_state ) == false
    return false if field_set?( :embargo_end_date ) && valid_embargo_date?( @embargo_end_date ) == false
    return false if field_set?( :status ) && [ PENDING_STATUS, SUBMITTED_STATUS ].include?( @status ) == false

    # if we specified anything else
    return @field_set.empty? == false

  end

  #
  # resubmit the metadata if any of the fields that are included have changed
  #
  def resubmit_metadata?
    return true if field_set?( :author_email )
    return true if field_set?( :author_first_name )
    return true if field_set?( :author_last_name )
    return true if field_set?( :author_department )
    return true if field_set?( :author_institution )
    return true if field_set?( :title )
    return true if field_set?( :degree )
    return true if field_set?( :published_date )
    return false
  end

  def apply_to_work( work, by_whom )

    if field_changed?(:abstract, work.description, @abstract )
      # update and audit the information
      audit_change( work.id, 'Abstract', work.description, @abstract, by_whom )
      work.description = @abstract
    end
    if field_changed?(:author_email, work.author_email, @author_email )
      # update and audit the information
      audit_change( work.id, 'Author Email', work.author_email, @author_email, by_whom )
      work.author_email = @author_email
    end
    if field_changed?(:author_first_name, work.author_first_name, @author_first_name )
      # update and audit the information
      audit_change( work.id, 'Author First Name', work.author_first_name, @author_first_name, by_whom )
      work.author_first_name = @author_first_name
    end
    if field_changed?(:author_last_name, work.author_last_name, @author_last_name )
      # update and audit the information
      audit_change( work.id, 'Author Last Name', work.author_last_name, @author_last_name, by_whom )
      work.author_last_name = @author_last_name
    end
    if field_changed?(:author_institution, work.author_institution, @author_institution )
      # update and audit the information
      audit_change( work.id, 'Author Institution', work.author_institution, @Rauthor_institution, by_whom )
      work.author_institution = @author_institution
    end
    if field_changed?(:author_department, work.department, @author_department )
      # update and audit the information
      audit_change( work.id, 'Department', work.department, @author_department, by_whom )
      work.department = @author_department
    end
    if field_changed?(:depositor_email, work.depositor, @depositor_email )
      # update and audit the information
      audit_change( work.id, 'Depositor Email', work.depositor, @depositor_email, by_whom )

      work.edit_users -= [ work.depositor ]
      work.edit_users += [ @depositor_email ]
      work.depositor = @depositor_email
    end
    if field_changed?(:degree, work.degree, @degree )
      # update and audit the information
      audit_change( work.id, 'Degree', work.degree, @degree, by_whom )
      work.degree = @degree
    end

    if field_changed?(:embargo_state, work.embargo_state, embargo_state_name )
      # update and audit the information
      audit_change( work.id, 'Embargo Type', work.embargo_state, embargo_state_name, by_whom )
      work.embargo_state = embargo_state_name

      # special case, we are setting the embargo without setting the end date
      if embargo_state_name != 'open' && field_set?( :embargo_end_date ) == false

        # and we dont already have an embargo date set
        if work.embargo_end_date.blank?
          @embargo_end_date = ( Time.now + 6.months ).strftime( '%Y-%m-%d' )
          @field_set << :embargo_end_date
        end
      end

      # another special case, setting the embargo to open should clear the embargo end date
      if embargo_state_name == 'open'
        @embargo_end_date = ''
        @field_set << :embargo_end_date
      end
    end

    # special case where date formats are converted
    if field_set?( :embargo_end_date )
      current = extract_date_from_datetime( work.embargo_end_date )
      if @embargo_end_date != current
        # update and audit the information
        audit_change( work.id, 'Embargo End Date', current, @embargo_end_date, by_whom )
        work.embargo_end_date = convert_string_to_datetime( @embargo_end_date )
      end
    end
    if field_changed?(:notes, work.notes, @notes )
      # update and audit the information
      audit_change( work.id, 'Notes', work.notes, @notes, by_whom )
      work.notes = @notes
    end
    # special case, we always *add* to an existing set of notes
    if field_set?( :admin_notes ) && @admin_notes.blank? == false
      # update and audit the information
      audit_add( work.id, 'Admin Notes', @admin_notes, by_whom )
      work.admin_notes = work.admin_notes + @admin_notes
    end
    if field_changed?(:rights, work.rights.first, @rights )
      # update and audit the information
      audit_change( work.id, 'Rights', work.rights.first, @rights, by_whom )
      work.rights = [ @rights ]
    end
    if field_changed?(:title, work.title.first, @title )
      # update and audit the information
      audit_change( work.id, 'Title', work.title.first, @title, by_whom )
      work.title = [ @title ]
    end

    if field_set?( :advisors )
      adv_array = relation_to_array( work.contributor )
      if field_changed?(:advisors, adv_array, @advisors )
        # update and audit the information
        audit_change( work.id, 'Advisors', adv_array, @advisors, by_whom )
        work.contributor = @advisors
      end
    end

    if field_changed?(:keywords, work.keyword, @keywords )
      # update and audit the information
      audit_change( work.id, 'Keywords', work.keyword, @keywords, by_whom )
      work.keyword = @keywords
    end
    if field_changed?(:language, work.language, @language )
      # update and audit the information
      audit_change( work.id, 'Language', work.language, @language, by_whom )
      work.language = @language
    end
    if field_changed?(:related_links, work.related_url, @related_links )
      # update and audit the information
      audit_change( work.id, 'Related Links', work.related_url, @related_links, by_whom )
      work.related_url = @related_links
    end
    if field_changed?(:sponsoring_agency, work.sponsoring_agency, @sponsoring_agency )
      # update and audit the information
      audit_change( work.id, 'Sponsoring Agency', work.sponsoring_agency, @sponsoring_agency, by_whom )
      work.sponsoring_agency = @sponsoring_agency
    end
    if field_changed?(:published_date, work.date_published, @published_date )
      # update and audit the information
      audit_change( work.id, 'Publication Date', work.date_published, @published_date, by_whom )
      work.date_published = @published_date
    end

    # another special case where status is updated
    if field_set?( :status )

      # if we are moving from a published work to a non-published one
      if @status == PENDING_STATUS && work.is_draft? == false
        audit_change( work.id, 'Published', 'true', 'false', by_whom )
        work.draft = 'true'
        revoke_doi( work )
      end

      # if we are moving from a non-published (draft) work to a published one
      if @status == SUBMITTED_STATUS && work.is_draft? == true
        audit_change( work.id, 'Published', 'false', 'true', by_whom )
        # dont actually do anything yet...
      end

    end

    # update the last modified date too
    work.date_modified = DateTime.now
  end

  # is this a draft work
  def is_draft?
    return @status != SUBMITTED_STATUS
  end

  # was this field specifically set during construction
  def field_set?( field )
    return @field_set.include?( field )
  end

  def convert_string_to_datetime( date )
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

  def extract_date_from_datetime( dt )
     return '' if dt.blank?
     return dt.strftime( '%Y-%m-%d' )
  end

  def field_changed?(field, before, after )

    # if we did not set the field then it has not changed
    return false if field_set?( field ) == false

    # if they are the same, then it has not changed
    return false if after == before

    #puts "==> #{field} has changed"
    return true
  end

  # check the end date to ensure it is valid
  def valid_embargo_date?( date )
    return true if date.blank?
    return convert_string_to_datetime( date ) != nil
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

  def audit_change( id, what, old_value, new_value, by_whom )
    WorkAudit.audit( id, by_whom, "#{what} updated from: '#{old_value}' to: '#{new_value}'" )
  end

  def audit_add( id, what, new_value, by_whom )
    WorkAudit.audit( id, by_whom, "#{what} updated to include '#{new_value}'" )
  end

  def relation_to_array( arr )
    return arr.map { |e| e.to_s }
  end

  def date_formatter( date_string )
    begin
      date_string.to_s.to_datetime.in_time_zone.strftime("%b %d, %Y %H:%M %Z")
    rescue
      ''
    end
  end

end

end
