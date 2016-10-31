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
    end
    puts "#{success_count} item(s) processed successfully, #{error_count} error(s) encountered"

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

     puts " ingesting #{File.basename( dirname )} (#{id}) and #{files.size} file(s)..."

     # create a payload from the document
     payload = create_ingest_payload( doc )

     # merge in any default attributes
     payload = merge_defaults( defaults, payload )
     #dump_ingest_payload( payload )

     # validate the payload
     ok, err = validate_ingest_payload( payload )
     if ok == false
       puts "ERROR: #{err} for #{File.basename( dirname )} (#{id}), continuing"
       return false
     end

     ok, work = create_new_item( depositor, payload )
     if ok == false
       puts "ERROR: creating new generic work, continuing"
       return false
     end

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
     payload[:title] = title if title.nil? == false

     # document abstract
     abstract = doc.at_path( 'abstract_t[0]')
     payload[:abstract] = abstract if abstract.nil? == false

     # document author
     if doc.at_path( 'mods_0_name_0_role_0_text_t[0]' ) == 'author'
       dept = doc.at_path( 'mods_0_name_0_description_t[0]' )
       cid = doc.at_path( 'mods_0_name_0_computing_id_t[0]' )
       fn = doc.at_path( 'mods_0_name_0_first_name_t[0]' )
       ln = doc.at_path( 'mods_0_name_0_last_name_t[0]' )
       payload[:author_computing_id] = cid if cid.nil? == false
       payload[:author_first_name] = fn if fn.nil? == false
       payload[:author_last_name] = ln if ln.nil? == false
       payload[:department] = dept if dept.nil? == false
     end

     # document advisor
     if doc.at_path( 'mods_0_person_1_role_0_text_t[0]' ) == 'advisor'
       dept = doc.at_path( 'mods_0_person_1_description_t[0]' )
       cid = doc.at_path( 'mods_0_person_1_computing_id_t[0]' )
       fn = doc.at_path( 'mods_0_person_1_first_name_t[0]' )
       ln = doc.at_path( 'mods_0_person_1_last_name_t[0]' )
       payload[:advisor_computing_id] = cid if cid.nil? == false
       payload[:advisor_first_name] = fn if fn.nil? == false
       payload[:advisor_last_name] = ln if ln.nil? == false
       payload[:advisor_department] = dept if dept.nil? == false
     end

     #
     # handle optional fields
     #

     # degree program
     degree = doc.at_path( 'mods_extension_degree_level_t[0]' )
     payload[:degree] = degree if degree.nil? == false

     # keywords
     #keywords = doc.at_path( 'subject/topic' )
     #payload[:keywords] = keywords if keywords.nil? == false

     return payload
  end

  #
  # validate the payload before we attempt to create a new document
  #
  def validate_ingest_payload( payload )

    # document title
    if payload[:title].nil?
      return false, 'missing document title'
    end

    # document abstract
    if payload[:abstract].nil?
    #  return false, 'missing document abstract'
    end

    if payload[:author_first_name].nil?
      return false, 'missing document author first name'
    end

    if payload[:author_last_name].nil?
      return false, 'missing document author last name'
    end

    if payload[:rights].nil?
      return false, 'missing document rights'
    end

    if payload[:language].nil?
      return false, 'missing document language'
    end

    if payload[:publisher].nil?
      return false, 'missing document publisher'
    end

    if payload[:institution].nil?
      return false, 'missing document institution'
    end

    #if payload[:xxx].nil?
    #  return false, 'missing document xxx'
    #end

    #  payload[:degree]

    return true
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
      w.author_email = TaskHelpers.default_email( payload[ :advisor_computing_id ] ) if payload[ :advisor_computing_id ]
      w.author_first_name = payload[ :author_first_name ] if payload[ :author_first_name ]
      w.author_last_name = payload[ :author_last_name ] if payload[ :author_last_name ]
      w.author_institution = payload[ :institution ] if payload[ :institution ]

      w.contributor = construct_contributor( payload )
      w.description = payload[ :abstract ]
      w.keyword = payload[ :keywords ] if payload[ :keywords ]
      w.date_created = CurationConcerns::TimeService.time_in_utc.strftime( "%Y-%m-%d" )

      #w.date_uploaded = DateTime.parse( h['date_uploaded'] ) if h['date_uploaded']
      #w.date_modified = DateTime.parse( h['date_modified'] ) if h['date_modified']
      #w.date_published = h['date_published'] if h['date_published']

      w.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      w.embargo_state = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      w.visibility_during_embargo = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      w.work_type = GenericWork::WORK_TYPE_THESIS
      w.draft = 'false'
      w.publisher = payload[ :publisher ] if payload[ :publisher ]
      w.department = payload[ :department ] if payload[ :department ]
      w.degree = payload[ :degree ] if payload[ :degree ]
      w.language = payload[ :language ] if payload[ :language ]

      w.rights = [ payload[ :rights ] ] if payload[ :rights ]
      w.license = GenericWork::DEFAULT_LICENSE

      #w.admin_notes =
      status, id = ServiceClient::EntityIdClient.instance.newid( w )
      if ServiceClient::EntityIdClient.instance.ok?( status )
        w.identifier = id
        w.permanent_url = GenericWork.doi_url( id )
      else
        puts "Cannot mint DOI (#{status})"
        ok = false
      end

    end

    return ok, work
  end

  #
  # If we have any contributor attributes, construct the necessary aggergate field
  #
  def construct_contributor( payload )
    if payload[:advisor_computing_id] || payload[:advisor_first_name] || payload[:advisor_last_name] || payload[:advisor_department]
       return [ TaskHelpers.contributor_fields( payload[:advisor_computing_id],
                                              payload[:advisor_first_name],
                                              payload[:advisor_last_name],
                                              payload[:advisor_department] ) ]
    end
    return []
  end
  #
  # list any assets that go with the document
  #
  def get_document_assets( dirname )
    files = []
    f = File.join( dirname, TaskHelpers::DOCUMENT_FILES_LIST )
    File.open( f, 'r').each do |line|
      tokens = line.strip.split( ":" )
      files << tokens[ 1 ]
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
        :institution => GenericWork::DEFAULT_INSTITUTION
               }
    return defaults
  end

  end   # namespace ingest

end   # namespace libra2

#
# end of file
#
