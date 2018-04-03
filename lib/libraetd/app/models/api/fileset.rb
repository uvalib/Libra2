require_dependency 'concerns/libraetd/solr_extract'

module API

class Fileset

  include Libra2::SolrExtract

  attr_accessor :id
  attr_accessor :source_name
  attr_accessor :file_name
  attr_accessor :file_size
  attr_accessor :file_url
  attr_accessor :thumb_url
  attr_accessor :date_uploaded
  attr_accessor :date_modified

  attr_accessor :filesets

  def initialize
    @id = ''
    @source_name = ''
    @file_name = ''
    @file_size = 0
    @file_url = ''
    @thumb_url = ''

    # the set of fields specified during construction
    @field_set = []
  end

  #
  # we create these work items from JSON records when accepting a set of updates
  # we have to keep track of what was set so we can distinguish it from a default
  # value that was not specifically set
  #
  def from_json( json )

    @file_name = set_field( :file_name, json ) unless set_field( :file_name, json ) == nil
    return self

  end

  def from_solr( solr, base_url )

    #puts "==> SOLR #{solr.inspect}"
    @id = solr['id'] unless solr['id'].blank?
    @source_name = solr_extract_first( solr, 'label' )
    @file_name = solr_extract_first( solr, 'title' )
    @file_size = solr_extract_only( solr, 'file_size', 'file_size_is' )
    # handle case where attribute was not found
    @file_size = 0 if @file_size == ''
    @file_size = get_file_size if @file_size == 0

    @file_url, @thumb_url = content_urls( base_url, @id )

    @date_uploaded = date_formatter solr_extract_only( solr, 'date_uploaded', 'date_uploaded_dtsi' )
    @date_modified = date_formatter solr_extract_only( solr, 'date_modified', 'date_modified_dtsi' )
    return self
  end

  def valid_for_update?

    # if we specified anything else
    return @field_set.empty? == false

  end

  def apply_to_fileset( fileset, by_whom )

    works = fileset.in_works
    work_id = works.empty? ? 'unknown' : works[0].id

    if field_changed?(:file_name, fileset.title[ 0 ], @file_name )
      # update and audit the information
      audit_change( work_id, "File #{fileset.label} display label", fileset.title[ 0 ], @file_name, by_whom )
      fileset.title = [ @file_name ]
    end

  end

  # ignore the @field_set when creating JSON
  def as_json(options={})
    options[:except] ||= ['field_set']
    super( options )
  end

  private

  def content_urls( base, id )
    return "#{download_url( base, id )}/content", "#{download_url( base, id )}/thumbnail"
  end

  def download_url( base, id )
     return "#{base}/downloads/#{id}"
  end

  def get_file_size
    filename = File.join( CurationConcerns.config.working_path, dirname_from_id( @id ), @source_name )
    begin
       st = File.stat( filename )
       return st.size
    rescue Exception => e
      # do nothing
    end
    return 0
  end

  def dirname_from_id( id )
    return '' if id.blank?
    return '' if id.size < 8
    return "#{id[0]}#{id[1]}/#{id[2]}#{id[3]}/#{id[4]}#{id[5]}/#{id[6]}#{id[7]}"
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

  # was this field specifically set during construction
  def field_set?( field )
    return @field_set.include?( field )
  end

  def field_changed?(field, before, after )

    # if we did not set the field then it has not changed
    return false if field_set?( field ) == false

    # if they are the same, then it has not changed
    return false if after == before

    #puts "==> #{field} has changed"
    return true
  end

  def audit_change( id, what, old_value, new_value, by_whom )
    WorkAudit.audit( id, by_whom, "#{what} updated from: '#{old_value}' to: '#{new_value}'" )
  end

  def date_formatter( date_string )
    begin
      date_string.to_s.to_datetime.in_time_zone.strftime("%b %d, %Y %H:%M %Z")
    rescue
      date_string
    end
  end

end

end
