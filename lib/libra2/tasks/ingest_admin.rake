#
# Tasks to manage ingest of legacy Libra data
#

require 'hash_at_path'

# pull in the helpers
require_dependency 'libra2/tasks/ingest_helpers'
include IngestHelpers

namespace :libra2 do

  namespace :ingest do

  # general attributes
  DEFAULT_DEPOSITOR = TaskHelpers::DEFAULT_USER
  DEFAULT_DEFAULT_FILE = 'data/default_ingest_attributes.yml'

  #
  # possible environment settings that affect the ingest behavior
  #
  # MAX_COUNT    - Maximum number of items to process
  # DUMP_PAYLOAD - Output the entire document metadata before saving
  # DRY_RUN      - Dont actually create the items
  # NO_FILES     - Dont import the associated files
  # NO_DOI       - Dont assign a DOI to the created items
  #

  #
  # ingest items that have been extracted from SOLR
  #
  desc "Ingest legacy Libra data; must provide the ingest directory; optionally provide a defaults file and start index"
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

    start = ARGV[ 3 ]
    if start.nil?
      start = "0"
    end
    task start.to_sym do ; end

    start_ix = start.to_i
    start_ix = 0 if start_ix.to_s != start

    # get the list of items to be ingested
    ingests = IngestHelpers.get_ingest_list( ingest_dir )
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
    ingests.each_with_index do | dirname, ix |
      next if ix < start_ix
      ok = ingest_new_item( defaults, user, File.join( ingest_dir, dirname ) )
      ok == true ? success_count += 1 : error_count += 1
      break if ENV[ 'MAX_COUNT' ] && ENV[ 'MAX_COUNT' ].to_i == ( success_count + error_count )
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
             puts "#{gw.work_source} #{gw.identifier || 'None'}"
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

     solr_doc, fedora_doc = IngestHelpers.load_ingest_content( dirname )
     id = solr_doc['id']
     assets = IngestHelpers.get_document_assets( dirname )

     puts "Ingesting #{File.basename( dirname )} (#{id}) and #{assets.size} asset(s)..."

     # create a payload from the document
     payload = create_ingest_payload( solr_doc, fedora_doc )

     # merge in any default attributes
     payload = apply_defaults( defaults, payload )

     # some fields with embedded quotes need to be escaped; handle this here
     payload = IngestHelpers.escape_fields( payload )

     # dump the fields as necessary...
     IngestHelpers.dump_ingest_payload( payload ) if ENV[ 'DUMP_PAYLOAD' ]

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

     # create the work
     ok, work = create_new_item( depositor, payload )
     if ok == true
       puts "New work created; id #{work.id} (#{work.identifier})"
     else
       #puts " ERROR: creating new generic work for #{File.basename( dirname )} (#{id})"
       #return false
       puts " WARNING: while creating generic work for #{File.basename( dirname )} (#{id})"
     end

     # handle no file upload
     return ok if ENV[ 'NO_FILES' ]

     # and upload each file
     assets.each do |asset|
       fileset = TaskHelpers.upload_file( depositor, work, File.join( dirname, asset[ :title ] ), asset[ :title ] )
       fileset.date_uploaded = DateTime.parse( asset[ :timestamp ] )
       fileset.save!
     end

     return ok
  end

  #
  # create a ingest payload from the Libra document
  #
  def create_ingest_payload( solr_doc, fedora_doc )


     payload = {}

     #
     # add all the required fields
     #

     # date and time attributes
     create_date = solr_doc.at_path( 'system_create_dt' )
     payload[ :create_date ] = IngestHelpers.extract_date( create_date ) if create_date.present?
     modified_date = solr_doc.at_path( 'system_modified_dt' )
     payload[ :modified_date ] = modified_date if modified_date.present?

     # document title
     title = solr_doc.at_path( 'mods_title_info_t[0]')
     payload[ :title ] = title if title.present?

     # document abstract (use the XML variant as it reflects the formatting better)
     # this was used for the 4th year theses
     #ab_node = fedora_doc.css( 'mods abstract' ).last
     # this was used for the subsequent items
     ab_node = fedora_doc.css( 'mods abstract' ).first
     abstract = ab_node.text if ab_node
     payload[ :abstract ] = abstract if abstract.present?

     # document author
     if solr_doc.at_path( 'mods_0_name_0_role_0_text_t[0]' ) == 'author'
       dept = solr_doc.at_path( 'mods_0_name_0_description_t[0]' )
       cid = solr_doc.at_path( 'mods_0_name_0_computing_id_t[0]' )
       fn = solr_doc.at_path( 'mods_0_name_0_first_name_t[0]' )
       ln = solr_doc.at_path( 'mods_0_name_0_last_name_t[0]' )
       payload[ :author_computing_id ] = cid if IngestHelpers.field_supplied( cid )
       payload[ :author_first_name ] = fn if IngestHelpers.field_supplied( fn )
       payload[ :author_last_name ] = ln if IngestHelpers.field_supplied( ln )
       payload[ :department ] = IngestHelpers.department_lookup( dept ) if IngestHelpers.field_supplied( dept )
     end

     # document advisor
     if solr_doc.at_path( 'mods_0_person_1_role_0_text_t[0]' ) == 'advisor'
       dept = solr_doc.at_path( 'mods_0_person_1_description_t[0]' )
       cid = solr_doc.at_path( 'mods_0_person_1_computing_id_t[0]' )
       fn = solr_doc.at_path( 'mods_0_person_1_first_name_t[0]' )
       ln = solr_doc.at_path( 'mods_0_person_1_last_name_t[0]' )
       payload[ :advisor_computing_id ] = cid if IngestHelpers.field_supplied( cid )
       payload[ :advisor_first_name ] = fn if IngestHelpers.field_supplied( fn )
       payload[ :advisor_last_name ] = ln if IngestHelpers.field_supplied( ln )
       payload[ :advisor_department ] = IngestHelpers.department_lookup( dept ) if IngestHelpers.field_supplied( dept )
     end

     # issue date
     issued_date = solr_doc.at_path( 'origin_info_date_issued_t[0]' )
     payload[ :issued ] = issued_date if issued_date.present?

     # embargo attributes
     embargo_type = solr_doc.at_path( 'release_to_t[0]' )
     payload[ :embargo_type ] = embargo_type if embargo_type.present?
     release_date = solr_doc.at_path( 'embargo_embargo_release_date_t[0]' )
     payload[ :embargo_release_date ] = release_date if release_date.present?
     payload[ :embargo_period ] =
         IngestHelpers.estimate_embargo_period( issued_date, release_date ) if issued_date.present? && release_date.present?

     # document source
     payload[ :source ] = solr_doc.at_path( 'id' )

     #
     # handle optional fields
     #

     # degree program
     degree = solr_doc.at_path( 'mods_extension_degree_level_t[0]' )
     payload[ :degree ] = degree if degree.present?

     # keywords
     keywords = solr_doc.at_path( 'subject_topic_t' )
     payload[ :keywords ] = keywords if keywords.present?

     # language
     language = solr_doc.at_path( 'language_lang_code_t[0]' )
     payload[ :language ] = IngestHelpers.language_code_lookup( language ) if language.present?

     # notes
     notes = solr_doc.at_path( 'note_t[0]' )
     payload[ :notes ] = notes if notes.present?

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
    warnings << 'missing language' if payload[ :language ].nil?
    warnings << 'missing notes' if payload[ :notes ].nil?
    #warnings << 'missing admin notes' if payload[ :admin_notes ].nil?

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
      w.contributor = IngestHelpers.construct_contributor( payload )
      w.description = payload[ :abstract ]
      w.keyword = payload[ :keywords ] if payload[ :keywords ]

      # date attributes
      w.date_created = payload[ :create_date ] if payload[ :create_date ]
      #w.date_uploaded = DateTime.parse( h['date_uploaded'] ) if h['date_uploaded']
      w.date_modified = DateTime.parse( payload[ :modified_date ] ) if payload[ :modified_date ]
      w.date_published = payload[ :issued ] if payload[ :issued ]

      # embargo attributes
      w.visibility = IngestHelpers.set_embargo_for_type( payload[:embargo_type ] )
      w.embargo_state = IngestHelpers.set_embargo_for_type( payload[:embargo_type ] )
      w.visibility_during_embargo = IngestHelpers.set_embargo_for_type( payload[:embargo_type ] )
      w.embargo_end_date = payload[ :embargo_release_date ] if payload[ :embargo_release_date ]
      w.embargo_period = payload[ :embargo_period ] if payload[ :embargo_period ]

      # assume standard and published work type
      w.work_type = GenericWork::WORK_TYPE_THESIS
      w.draft = 'false'

      w.publisher = payload[ :publisher ] if payload[ :publisher ]
      w.department = payload[ :department ] if payload[ :department ]
      w.degree = payload[ :degree ] if payload[ :degree ]
      w.language = payload[ :language ] if payload[ :language ]

      w.notes = payload[ :notes ] if payload[ :notes ]
      w.rights = [ payload[ :rights ] ] if payload[ :rights ]
      w.license = GenericWork::DEFAULT_LICENSE

      w.admin_notes = payload[ :admin_notes ] if payload[ :admin_notes ]
      w.work_source = payload[ :source ] if payload[ :source ]

      # mint and assign the DOI
      if ENV[ 'NO_DOI' ].blank?
         status, id = ServiceClient::EntityIdClient.instance.newid( w )
         if ServiceClient::EntityIdClient.instance.ok?( status )
            w.identifier = id
            w.permanent_url = GenericWork.doi_url( id )
         else
            puts "ERROR: cannot mint DOI (#{status})"
            ok = false
         end
      end
    end

    # update the DOI metadata if necessary
    if ENV[ 'NO_DOI' ].blank?
      if ok && work.is_draft? == false
        ok = update_doi_metadata( work )
      end
    else
      puts "INFO: no DOI assigned..."
    end

    return ok, work
  end

  #
  # apply any default values and behavior to the standard payload
  #
  def apply_defaults( defaults, payload )

    # merge in defaults
    defaults.each { |k, v|

      case k

        when :notes
          next if v.blank?

          # create the admin notes for this item
          new_notes = payload[ :notes ] || ''
          new_notes += "\n\n" if new_notes.blank? == false

          original_create_date = payload[ :create_date ]
          time_now = CurationConcerns::TimeService.time_in_utc.strftime( "%Y-%m-%d %H:%M:%S" )
          new_notes += "#{v.gsub( 'LIBRA1_CREATE_DATE', original_create_date ).gsub( 'CURRENT_DATE', time_now )}"
          payload[ :notes ] = new_notes

        when :force_embargo_period
          payload[ :embargo_period ] = v
          if payload[ :issued ]
             payload[ :embargo_release_date ] = IngestHelpers.calculate_embargo_release_date( payload[ :issued ], v )
          else
             payload[ :embargo_release_date ] = GenericWork.calculate_embargo_release_date( v )
          end

       else if payload.key?( k ) == false
               payload[ k ] = v
            end
       end
    }

    return payload
  end

  #
  # load the hash of default attributes
  #
  def load_defaults( filename )

    begin
      config_erb = ERB.new( IO.read( filename ) ).result( binding )
    rescue StandardError => ex
      raise( "#{filename} could not be parsed with ERB. \n#{ex.inspect}" )
    end

    begin
      yml = YAML.load( config_erb )
    rescue Psych::SyntaxError => ex
      raise "#{filename} could not be parsed as YAML. \nError #{ex.message}"
    end

    config = yml.symbolize_keys
    return config.symbolize_keys || {}
  end

  end   # namespace ingest

end   # namespace libra2

#
# end of file
#
