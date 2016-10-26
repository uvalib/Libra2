#
# Tasks to manage ingest if legacy Libra data
#

namespace :libra2 do

  namespace :ingest do

  # general attributes
  DEFAULT_DEPOSITOR = TaskHelpers::DEFAULT_USER

  #
  # extract items from SOLR according to the query file and maximum number of rows
  #
  desc "Ingest legacy Libra data; must provide the extract directory"
  task legacy_ingest: :environment do |t, args|

    work_dir = ARGV[ 1 ]
    if work_dir.nil?
      puts "ERROR: no extract directory specified, aborting"
      next
    end
    task work_dir.to_sym do ; end

    dirname = get_libra_extract_list( work_dir )
    if dirname.empty?
      puts "ERROR: extract directory does not contain contains Libra items, aborting"
      next
    end

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

    count = 0
    dirname.each do | dirname |
      ingest_new_item( user, File.join( work_dir, dirname ) )
      count += 1
    end
    puts "#{count} item(s) processed successfully"

  end

  #
  # helpers
  #

  #
  # convert a set of Libra extract assets into a new Libra record
  #
  def ingest_new_item( depositor, dirname )

     id = load_libra_id( dirname )
     doc = load_libra_doc( dirname )
     files = load_libra_files( dirname )

     puts " ingesting #{File.basename( dirname )} (#{id}) and #{files.size} file(s)..."

     ok, payload = create_standard_payload( doc )
     if ok == false
        puts "ERROR: creating ingest payload, aborting"
        return false
     end

     ok, work = create_new_item( depositor, payload )
     if ok == false
       puts "ERROR: creating new generic work, aborting"
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
  def create_standard_payload( doc )
     payload = {}

     # add all the required fields
     if doc['titleInfo' ] && doc['titleInfo' ][ 'title' ]
        payload[:title] = doc['titleInfo' ][ 'title' ]
     else
        puts "Missing title information"
        return false, {}
     end

     if doc[ 'abstract' ]
       payload[:abstract] = doc[ 'abstract' ]
     else
       puts "Missing abstract information"
       return false, {}
     end

     # handle optional fields
     if doc['extension' ] && doc['extension' ][ 'degree' ] && doc['extension' ][ 'degree' ][ 'level' ]
       payload[:degree] = doc['extension' ][ 'degree' ][ 'level' ]
     else
       #puts "Missing degree information"
       #return false, {}
     end

     return true, payload
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
      #w.author_email = email
      w.author_first_name = 'dave'
      w.author_last_name = 'gee'
      w.author_institution = GenericWork::DEFAULT_INSTITUTION

      #w.contributor =
      w.description = payload[ :abstract ]
      w.date_created = CurationConcerns::TimeService.time_in_utc.strftime( "%Y-%m-%d" )

      #w.date_uploaded = DateTime.parse( h['date_uploaded'] ) if h['date_uploaded']
      #w.date_modified = DateTime.parse( h['date_modified'] ) if h['date_modified']
      #w.date_published = h['date_published'] if h['date_published']

      w.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      w.embargo_state = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      w.visibility_during_embargo = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      w.work_type = GenericWork::WORK_TYPE_THESIS
      w.draft = 'false'
      w.publisher = GenericWork::DEFAULT_PUBLISHER
      w.department = payload[ :department ] if payload[:department]
      w.degree = payload[ :degree ] if payload[:degree]
      w.language = GenericWork::DEFAULT_LANGUAGE

      w.rights = 'None (users must comply with ordinary copyright law)'
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
  # load the Libra json data from the specified directory
  #
  def load_libra_files( dirname )
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
  def load_libra_doc( dirname )
    return load_json_doc( File.join( dirname, TaskHelpers::DOCUMENT_JSON_FILE ) )
  end

  #
  # load the Libra json data from the specified directory
  #
  def load_libra_id( dirname )
    doc = load_json_doc( File.join( dirname, TaskHelpers::DOCUMENT_ID_FILE ) )
    return doc[ 'id' ]
  end

  #
  # load the file containing json data
  #
  def load_json_doc( filename )
    File.open( filename, 'r') do |file|
      json_str = file.read( )
      doc = JSON.parse json_str
      return doc
    end
  end

  #
  # get the list of Libra extract items from the work directory
  #
  def get_libra_extract_list( dirname )
    return TaskHelpers.get_directory_list( dirname, /^libra./ )
  end

  end   # namespace ingest

end   # namespace libra2

#
# end of file
#
