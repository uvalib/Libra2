#
# Tasks to manage ingest of legacy Libra data
#

require 'hash_at_path'

namespace :libra2 do

  namespace :ingest do

  # general attributes
  DEFAULT_DEPOSITOR = TaskHelpers::DEFAULT_USER
  DEFAULT_DEFAULT_FILE = 'data/default_ingest_attributes.txt'

  #
  # ingest items that have been extracted from SOLR
  #
  desc "Ingest legacy Libra data; must provide the ingest directory; optionally provide a defaults file"
  task legacy_ingest: :environment do |t, args|

    ingest_dir = ARGV[ 1 ]
    if ingest_dir.nil?
      puts "ERROR: no ingest directory specified, aborting"
      next
    end
    task ingest_dir.to_sym do ; end

    defaults_file = ARGV[ 2 ]
    if defaults_file.nil?
      defaults_file = DEFAULT_DEFAULT_FILE
    end
    task defaults_file.to_sym do ; end

    # get the list of items to be ingested
    ingests = get_ingest_list( ingest_dir )
    if ingests.empty?
      puts "ERROR: ingest directory does not contain contains any items, aborting"
      next
    end

    # load any default attributes
    defaults = load_defaults( defaults_file )

    # load depositor information
    depositor = Helpers::EtdHelper::lookup_user( DEFAULT_DEPOSITOR )
    if depositor.nil?
      puts "ERROR: Cannot locate depositor info (#{DEFAULT_DEPOSITOR})"
      next
    end

    user = User.find_by_email( depositor.email )
    if user.nil?
      puts "ERROR: Cannot lookup depositor info (#{depositor.email})"
      next
    end

    success_count = 0
    error_count = 0
    ingests.each do | dirname |
      ok = ingest_new_item( defaults, user, File.join( ingest_dir, dirname ) )
      ok == true ? success_count += 1 : error_count += 1
      #break
    end
    puts "#{success_count} item(s) processed successfully, #{error_count} error(s) encountered"

  end

  desc "Enumerate legacy Libra items"
  task legacy_list: :environment do |t, args|

    count = 0
    GenericWork.search_in_batches( {} ) do |group|
      group.each do |gw_solr|

        begin
           gw = GenericWork.find( gw_solr['id'] )
           if gw.is_legacy_thesis?
             puts "#{gw.work_source} -> #{gw.permanent_url || 'None'}"
             count += 1
           end
        rescue => e
        end

      end

      puts "Listed #{count} legacy work(s)"
    end

  end

  #
  # helpers
  #

  #
  # convert a set of Libra extract assets into a new Libra record
  #
  def ingest_new_item( defaults, depositor, dirname )

     doc = load_solr_doc( dirname )
     id = doc['id']
     files = get_document_assets( dirname )

     puts "Ingesting #{File.basename( dirname )} (#{id}) and #{files.size} file(s)..."

     # create a payload from the document
     payload = create_ingest_payload( doc )

     # merge in any default attributes
     payload = merge_defaults( defaults, payload )
     #dump_ingest_payload( payload )

     # validate the payload
     errors, warnings = validate_ingest_payload( payload )

     if errors.empty? == false
       puts " ERROR(S) identified for #{File.basename( dirname )} (#{id})"
       puts " ==> #{errors.join( "\n ==> " )}"
       return false
     end

     if warnings.empty? == false
       puts " WARNING(S) identified for #{File.basename( dirname )} (#{id}), continuing anyway"
       puts " ==> #{warnings.join( "\n ==> " )}"
     end

     # handle dry running
     return true if ENV[ 'DRY_RUN' ]

     # creazte the work
     ok, work = create_new_item( depositor, payload )
     if ok == false
       puts " ERROR: creating new generic work for #{File.basename( dirname )} (#{id})"
       return false
     end

     # and upload each file
     files.each do |f|
       TaskHelpers.upload_file( depositor, work, File.join( dirname, f ) )
     end

     return true
  end

  #
  # create a ingest payload from the Libra document
  #
  def create_ingest_payload( doc )
     payload = {}

     #
     # add all the required fields
     #

     # document title
     title = doc.at_path( 'mods_title_info_t[0]')
     payload[ :title ] = title if title.nil? == false

     # document abstract
     abstract = doc.at_path( 'abstract_t[0]')
     payload[ :abstract ] = abstract if abstract.nil? == false

     # document author
     if doc.at_path( 'mods_0_name_0_role_0_text_t[0]' ) == 'author'
       dept = doc.at_path( 'mods_0_name_0_description_t[0]' )
       cid = doc.at_path( 'mods_0_name_0_computing_id_t[0]' )
       fn = doc.at_path( 'mods_0_name_0_first_name_t[0]' )
       ln = doc.at_path( 'mods_0_name_0_last_name_t[0]' )
       payload[ :author_computing_id ] = cid if cid.nil? == false
       payload[ :author_first_name ] = fn if fn.nil? == false
       payload[ :author_last_name ] = ln if ln.nil? == false
       payload[ :department ] = dept if dept.nil? == false
     end

     # document advisor
     if doc.at_path( 'mods_0_person_1_role_0_text_t[0]' ) == 'advisor'
       dept = doc.at_path( 'mods_0_person_1_description_t[0]' )
       cid = doc.at_path( 'mods_0_person_1_computing_id_t[0]' )
       fn = doc.at_path( 'mods_0_person_1_first_name_t[0]' )
       ln = doc.at_path( 'mods_0_person_1_last_name_t[0]' )
       payload[ :advisor_computing_id ] = cid if cid.nil? == false
       payload[ :advisor_first_name ] = fn if fn.nil? == false
       payload[ :advisor_last_name ] = ln if ln.nil? == false
       payload[ :advisor_department ] = dept if dept.nil? == false
     end

     # issue date
     issued = doc.at_path( 'origin_info_date_issued_t[0]' )
     payload[ :issued ] = issued if issued.nil? == false

     # embargo attributes
     embargo_type = doc.at_path( 'release_to_t[0]' )
     payload[ :embargo_type ] = embargo_type if embargo_type.nil? == false
     release_date = doc.at_path( 'embargo_embargo_release_date_t[0]' )
     payload[ :embargo_release_date ] = release_date if release_date.nil? == false

     # document source
     payload[ :source ] = doc.at_path( 'id' )

     # date and time attributes
     date = doc.at_path( 'system_create_dt' )
     payload[ :create_date ] = extract_date( date ) if date.nil? == false
     date = doc.at_path( 'system_modified_dt' )
     payload[ :modified_date ] = date if date.nil? == false

     #
     # handle optional fields
     #

     # degree program
     degree = doc.at_path( 'mods_extension_degree_level_t[0]' )
     payload[ :degree ] = degree if degree.nil? == false

     # keywords
     keywords = doc.at_path( 'subject_topic_t' )
     payload[ :keywords ] = keywords if keywords.nil? == false

     return payload
  end

  #
  # validate the payload before we attempt to create a new document
  #
  def validate_ingest_payload( payload )

    errors = []
    warnings = []

    #
    # ensure required fields first...
    #

    # document title
    errors << 'missing title' if payload[ :title ].nil?

    # author attributes
    errors << 'missing author first name' if payload[ :author_first_name ].nil?
    errors << 'missing author last name' if payload[ :author_last_name ].nil?

    # other required attributes
    errors << 'missing rights' if payload[ :rights ].nil?
    errors << 'missing language' if payload[ :language ].nil?
    errors << 'missing publisher' if payload[ :publisher ].nil?
    errors << 'missing institution' if payload[ :institution ].nil?
    errors << 'missing source' if payload[ :source ].nil?
    errors << 'missing issued date' if payload[ :issued ].nil?

    errors << 'missing license' if payload[ :license ].nil?

    #
    # then warn about optional fields
    #

    warnings << 'missing author computing id' if payload[ :author_computing_id ].nil?
    warnings << 'missing advisor computing id' if payload[ :advisor_computing_id ].nil?
    warnings << 'missing advisor first name' if payload[ :advisor_first_name ].nil?
    warnings << 'missing advisor last name' if payload[ :advisor_last_name ].nil?
    warnings << 'missing advisor department' if payload[ :advisor_department ].nil?


    warnings << 'missing abstract' if payload[ :abstract ].nil?
    warnings << 'missing keywords' if payload[ :keywords ].nil?
    warnings << 'missing degree' if payload[ :degree ].nil?
    warnings << 'missing create date' if payload[ :create_date ].nil?
    warnings << 'missing modified date' if payload[ :modified_date ].nil?
    warnings << 'missing admin notes' if payload[ :admin_notes ].nil?

    return errors, warnings
  end

  #
  # create a new generic work item
  #
  def create_new_item( depositor, payload )

    ok = true
    work = GenericWork.create!( title: [ payload[ :title ] ] ) do |w|

      # generic work attributes
      w.apply_depositor_metadata( depositor )
      w.creator = depositor.email
      w.author_email = TaskHelpers.default_email( payload[ :author_computing_id ] ) if payload[ :author_computing_id ]
      w.author_first_name = payload[ :author_first_name ] if payload[ :author_first_name ]
      w.author_last_name = payload[ :author_last_name ] if payload[ :author_last_name ]
      w.author_institution = payload[ :institution ] if payload[ :institution ]
      w.contributor = construct_contributor( payload )
      w.description = payload[ :abstract ]
      w.keyword = payload[ :keywords ] if payload[ :keywords ]

      # date attributes
      w.date_created = payload[ :create_date ] if payload[ :create_date ]
      #w.date_uploaded = DateTime.parse( h['date_uploaded'] ) if h['date_uploaded']
      w.date_modified = DateTime.parse( payload[ :modified_date ] ) if payload[ :modified_date ]
      w.date_published = payload[ :issued ] if payload[ :issued ]

      # embargo attributes
      w.visibility = set_embargo_for_type( payload[:embargo_type ] )
      w.embargo_state = set_embargo_for_type( payload[:embargo_type ] )
      w.visibility_during_embargo = set_embargo_for_type( payload[:embargo_type ] )
      w.embargo_end_date = payload[ :embargo_release_date ] if payload[ :embargo_release_date ]
      w.embargo_period = GenericWork::EMBARGO_VALUE_6_MONTH if payload[ :embargo_release_date ]

      # assume standard and published work type
      w.work_type = GenericWork::WORK_TYPE_THESIS
      w.draft = 'false'

      w.publisher = payload[ :publisher ] if payload[ :publisher ]
      w.department = payload[ :department ] if payload[ :department ]
      w.degree = payload[ :degree ] if payload[ :degree ]
      w.language = payload[ :language ] if payload[ :language ]

      w.rights = [ payload[ :rights ] ] if payload[ :rights ]
      w.license = GenericWork::DEFAULT_LICENSE

      w.admin_notes = payload[ :admin_notes ]
      w.work_source = payload[ :source ]

      # mint and assign the DOI
      status, id = ServiceClient::EntityIdClient.instance.newid( w )
      if ServiceClient::EntityIdClient.instance.ok?( status )
        w.identifier = id
        w.permanent_url = GenericWork.doi_url( id )
      else
        puts "Cannot mint DOI (#{status})"
        ok = false
      end

    end

    # update the DOI metadata if necessary
    if ok && work.is_draft? == false
      update_doi_metadata( work )
    end

    return ok, work
  end

  #
  # If we have any contributor attributes, construct the necessary aggergate field
  #
  def construct_contributor( payload )
    if payload[ :advisor_computing_id] || payload[ :advisor_first_name] || payload[ :advisor_last_name] || payload[ :advisor_department]
       return [ TaskHelpers.contributor_fields( payload[ :advisor_computing_id],
                                              payload[ :advisor_first_name],
                                              payload[ :advisor_last_name],
                                              payload[ :advisor_department] ) ]
    end
    return []
  end

  #
  # list any assets that go with the document
  #
  def get_document_assets( dirname )

    files = []
    f = File.join( dirname, TaskHelpers::DOCUMENT_FILES_LIST )
    begin
    File.open( f, 'r').each do |line|
      tokens = line.strip.split( ":" )
      files << tokens[ 1 ]
    end
    rescue Errno::ENOENT
      # do nothing, no files...
    end

    return files
  end

  #
  # load the Libra json data from the specified directory
  #
  def load_solr_doc( dirname )
    return TaskHelpers.load_json_doc( File.join( dirname, TaskHelpers::DOCUMENT_JSON_FILE ) )
  end

  #
  # get the list of Libra extract items from the work directory
  #
  def get_ingest_list( dirname )
    return TaskHelpers.get_directory_list( dirname, /^solr./ )
  end

  #
  # simple payload dump for debugging
  #
  def dump_ingest_payload( payload )
    payload.each { |k, v|
       puts " ==> #{k} -> #{v}"
    }
  end

  #
  # merge in any default value to the standard payload
  #
  def merge_defaults( defaults, payload )
    defaults.each { |k, v|
       if payload.key?( k ) == false
         payload[ k ] = v
       end
    }
    return payload
  end

  #
  # load the hash of default attributes
  #
  def load_defaults( filename )

    defaults = {
        :rights => 'None (users must comply with ordinary copyright law)',
        :language => GenericWork::DEFAULT_LANGUAGE,
        :publisher => GenericWork::DEFAULT_PUBLISHER,
        :institution => GenericWork::DEFAULT_INSTITUTION,
        :license => GenericWork::DEFAULT_LICENSE,
        :admin_notes => [ "Ingested on #{CurationConcerns::TimeService.time_in_utc.strftime( "%Y-%m-%d %H:%M:%S" )}" ]
               }
    return defaults
  end

  #
  # extract a date from a fully specified date/time
  #
  def extract_date( date )
    matches = /^(\d{4}-\d{2}-\d{2})/.match( date )
    return matches[ 1 ] if matches
    return date
  end

  #
  # Determine the embargo type from the metadata
  #
  def set_embargo_for_type(embargo )
    return Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC if embargo.blank?
    return Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED if embargo == 'uva'

    # none of the above
    return Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  end

  #
  #
  #
  def solr_extract_first( json, fn )

    field = Solrizer.solr_name( fn )
    return json[ field ][ 0 ] if json.key? field
    return ''

  end

  end   # namespace ingest

end   # namespace libra2

#
# end of file
#
