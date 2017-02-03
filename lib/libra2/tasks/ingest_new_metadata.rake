#
# Tasks to manage ingest of new metadata
#

# pull in the helpers
require_dependency 'libra2/tasks/ingest_helpers'
include IngestHelpers

namespace :libra2 do

  namespace :ingest do

  # general attributes
  #DEFAULT_DEPOSITOR = TaskHelpers::DEFAULT_USER
  #DEFAULT_DEFAULT_FILE = 'data/default_ingest_attributes.yml'
  #MAX_ABSTRACT_LENGTH = 32766

  #
  # possible environment settings that affect the ingest behavior
  #
  # MAX_COUNT    - Maximum number of items to process
  # DUMP_PAYLOAD - Output the entire document metadata before saving
  # DRY_RUN      - Dont actually create the items
  # NO_DOI       - Dont assign a DOI to the created items
  #

  #
  # ingest metadata
  #
  desc "Ingest new metadata; must provide the ingest directory; optionally provide a defaults file and start index"
  task new_metadata: :environment do |t, args|

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
    defaults = IngestHelpers.load_config_file( defaults_file )

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
    ingests.each_with_index do | filename, ix |
      next if ix < start_ix
      ok = ingest_metadata( defaults, user, File.join( ingest_dir, filename ) )
      ok == true ? success_count += 1 : error_count += 1
      break if ENV[ 'MAX_COUNT' ] && ENV[ 'MAX_COUNT' ].to_i == ( success_count + error_count )
    end
    puts "#{success_count} item(s) processed successfully, #{error_count} error(s) encountered"

  end

  #
  # helpers
  #

  #
  # convert an XML file into a new metadata record
  #
  def ingest_metadata( defaults, depositor, filename )

     xml_doc = IngestHelpers.load_ingest_content( filename )
     #id = solr_doc['id']

     puts "Ingesting #{filename}..."

     # create a payload from the document
     payload = create_ingest_payload( xml_doc )

     # merge in any default attributes
     payload = apply_defaults( defaults, payload )

     # some fields with embedded quotes need to be escaped; handle this here
     payload = IngestHelpers.escape_fields( payload )

     # dump the fields as necessary...
     IngestHelpers.dump_ingest_payload( payload ) if ENV[ 'DUMP_PAYLOAD' ]

     # validate the payload
     errors, warnings = validate_ingest_payload( payload )

     if errors.empty? == false
       puts " ERROR(S) identified for #{filename}"
       puts " ==> #{errors.join( "\n ==> " )}"
       return false
     end

     if warnings.empty? == false
       puts " WARNING(S) identified for #{filename}, continuing anyway"
       puts " ==> #{warnings.join( "\n ==> " )}"
     end

     # handle dry running
     return true if ENV[ 'DRY_RUN' ]

     # create the work
     ok, work = create_new_item( depositor, payload )
     if ok == true
       puts "New work created; id #{work.id} (#{work.identifier || 'none'})"
     else
       #puts " ERROR: creating new generic work for #{File.basename( dirname )} (#{id})"
       #return false
       puts " WARNING: while creating generic work for #{File.basename( dirname )} (#{id})"
     end

     # create a record of the actual work id
     if work != nil
        IngestHelpers.set_ingest_id( dirname, work.id )
     end

     return ok
  end

  #
  # create a ingest payload from the Libra document
  #
  def create_ingest_payload( xml_doc )


     payload = {}

     #
     # add all the required fields
     #

     # date and time attributes
     #create_date = solr_doc.at_path( 'system_create_dt' )
     #payload[ :create_date ] = IngestHelpers.extract_date( create_date ) if create_date.present?
     #modified_date = solr_doc.at_path( 'system_modified_dt' )
     #payload[ :modified_date ] = modified_date if modified_date.present?

     # document title
     node = xml_doc.css( 'mods titleInfo title' ).first
     title = node.text if node
     payload[ :title ] = title if title.present?

     # document abstract
     node = xml_doc.css( 'mods abstract' ).first
     abstract = node.text if node
     payload[ :abstract ] = abstract if IngestHelpers.field_supplied( abstract )

     # document author
     found = false
     name_nodes = xml_doc.css( 'mods name' )
     name_nodes.each do |nn|
       nodes = nn.css( 'roleTerm' )
       nodes.each do |rt|
         if rt.get( 'type' ) == 'text' && rt.text == 'author'
           found = true
           break
         end
       end
       if found
         #puts "Found AUTHOR"
         fn, ln, dept = '', '', ''

         nodes = nn.css( 'namePart' )
         nodes.each do |np|
           case np.get( 'type' )
             when 'given'
               fn = np.text
             when 'family'
               ln = np.text
           end
         end

         node = nn.css( 'description' ).first
         dept = node.text if node

         payload[ :author_first_name ] = fn if IngestHelpers.field_supplied( fn )
         payload[ :author_last_name ] = ln if IngestHelpers.field_supplied( ln )
         payload[ :department ] = dept if IngestHelpers.field_supplied( dept )
         break
       end
     end

     # document advisors
     advisor_number = 1
     name_nodes = xml_doc.css( 'mods name' )
     name_nodes.each do |nn|
       nodes = nn.css( 'roleTerm' )
       nodes.each do |rt|
         if rt.get( 'type' ) == 'text' && rt.text == 'advisor'
            puts "Found ADVISOR"
         end
       end
     end

     #if solr_doc.at_path( 'mods_0_name_0_role_0_text_t[0]' ) == 'author'
     #  dept = solr_doc.at_path( 'mods_0_name_0_description_t[0]' )
     #  cid = solr_doc.at_path( 'mods_0_name_0_computing_id_t[0]' )
     #  fn = solr_doc.at_path( 'mods_0_name_0_first_name_t[0]' )
     #
     # payload[ :author_computing_id ] = cid if IngestHelpers.field_supplied( cid )
     #  payload[ :author_first_name ] = fn if IngestHelpers.field_supplied( fn )
     #  payload[ :author_last_name ] = ln if IngestHelpers.field_supplied( ln )
     #  payload[ :department ] = IngestHelpers.department_lookup( dept ) if IngestHelpers.field_supplied( dept )
     #end

     # document advisor
     #payload[ :advisors ] = []
     #advisor_number = 1
     #while true
     #   added, payload[ :advisors ] = add_advisor( solr_doc, advisor_number, payload[ :advisors ] )
     #   break unless added
     #   advisor_number += 1
     #end

     # issue date
     node = xml_doc.css( 'mods dateIssued' ).first
     issued_date = node.text if node
     payload[ :issued ] = issued_date if issued_date.present?

     # embargo attributes
     #embargo_type = solr_doc.at_path( 'release_to_t[0]' )
     #payload[ :embargo_type ] = embargo_type if embargo_type.present?
     #release_date = solr_doc.at_path( 'embargo_embargo_release_date_t[0]' )
     #payload[ :embargo_release_date ] = release_date if release_date.present?
     #payload[ :embargo_period ] =
     #    IngestHelpers.estimate_embargo_period( issued_date, release_date ) if issued_date.present? && release_date.present?

     # document source
     node = xml_doc.css( 'mods identifier' ).first
     source = node.text if node
     payload[ :source ] = "new:#{source}" if source.present?

     #
     # handle optional fields
     #

     # degree program
     #degree = solr_doc.at_path( 'mods_extension_degree_level_t[0]' )
     #payload[ :degree ] = degree if degree.present?

     # keywords
     #keywords = solr_doc.at_path( 'subject_topic_t' )
     #payload[ :keywords ] = keywords if keywords.present?

     # language
     node = xml_doc.css( 'mods language' ).first
     language = node.text if node
     payload[ :language ] = IngestHelpers.language_code_lookup( language ) if language.present?

     # notes
     node = xml_doc.css( 'mods note' ).first
     notes = node.text if node
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

    # check for an abstract that exceeds the maximum size
    if payload[ :abstract ].blank? == false && payload[ :abstract ].length > MAX_ABSTRACT_LENGTH
      errors << "abstract too large (< #{MAX_ABSTRACT_LENGTH} bytes)"
    end

    # ensure an embargo release date is defined if specified
    if payload[:embargo_type].blank? == false && payload[:embargo_type] == 'uva' && payload[:embargo_release_date].blank?
      errors << 'unspecified embargo release date for embargo item'
    end

    #
    # then warn about optional fields
    #

    warnings << 'missing author computing id' if payload[ :author_computing_id ].nil?
    warnings << 'missing advisor(s)' if payload[ :advisors ].blank?

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
      w.contributor = payload[ :advisors ]
      w.description = payload[ :abstract ]
      w.keyword = payload[ :keywords ] if payload[ :keywords ]

      # date attributes
      w.date_created = payload[ :create_date ] if payload[ :create_date ]
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
      #if ENV[ 'NO_DOI' ].blank?
      #   status, id = ServiceClient::EntityIdClient.instance.newid( w )
      #   if ServiceClient::EntityIdClient.instance.ok?( status )
      #      w.identifier = id
      #      w.permanent_url = GenericWork.doi_url( id )
      #   else
      #      puts "ERROR: cannot mint DOI (#{status})"
      #      ok = false
      #   end
      #end
    end

    # update the DOI metadata if necessary
    #if ENV[ 'NO_DOI' ].blank?
    #  if ok && work.is_draft? == false
    #    ok = update_doi_metadata( work )
    #  end
    #else
    #  puts "INFO: no DOI assigned..."
    #end

    return ok, work
  end

  #
  # adds another advisor if we can locate one
  #
  def add_advisor( solr_doc, advisor_number, advisors )

    if solr_doc.at_path( "mods_0_person_#{advisor_number}_role_0_text_t[0]" ) == 'advisor'
      cid = solr_doc.at_path( "mods_0_person_#{advisor_number}_computing_id_t[0]" )
      fn = solr_doc.at_path( "mods_0_person_#{advisor_number}_first_name_t[0]" )
      ln = solr_doc.at_path( "mods_0_person_#{advisor_number}_last_name_t[0]" )
      dept = solr_doc.at_path( "mods_0_person_#{advisor_number}_description_t[0]" )
      ins = solr_doc.at_path( "mods_0_person_#{advisor_number}_institution_t[0]" )

      advisor_computing_id = IngestHelpers.field_supplied( cid ) ? cid : ''
      advisor_first_name = IngestHelpers.field_supplied( fn ) ? fn : ''
      advisor_last_name = IngestHelpers.field_supplied( ln ) ? ln : ''
      advisor_department = IngestHelpers.field_supplied( dept ) ? IngestHelpers.department_lookup( dept ) : ''
      advisor_institution = IngestHelpers.field_supplied( ins ) ? ins : ''

      if advisor_computing_id.blank? == false ||
         advisor_first_name.blank? == false ||
         advisor_last_name.blank? == false ||
         advisor_department.blank? == false ||
         advisor_institution.blank? == false
         adv = TaskHelpers.contributor_fields( advisor_number - 1,
                                               advisor_computing_id,
                                               advisor_first_name,
                                               advisor_last_name,
                                               advisor_department,
                                               advisor_institution )

         return true, advisors << adv
      end
    end

    # could not find the next advisor, we are done
    return false, advisors
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
        #  new_notes = payload[ :notes ] || ''
        #  new_notes += "\n\n" if new_notes.blank? == false

        #  original_create_date = payload[ :create_date ]
        #  time_now = CurationConcerns::TimeService.time_in_utc.strftime( "%Y-%m-%d %H:%M:%S" )
        #  new_notes += "#{v.gsub( 'LIBRA1_CREATE_DATE', original_create_date ).gsub( 'CURRENT_DATE', time_now )}"
        #  payload[ :notes ] = new_notes

        #when :force_embargo_period
        #  payload[ :embargo_period ] = v
        #  if payload[ :issued ]
        #     payload[ :embargo_release_date ] = IngestHelpers.calculate_embargo_release_date( payload[ :issued ], v )
        #  else
        #     payload[ :embargo_release_date ] = GenericWork.calculate_embargo_release_date( v )
        #  end

       else if payload.key?( k ) == false
               payload[ k ] = v
            end
       end
    }

    return payload
  end

  end   # namespace ingest

end   # namespace libra2

#
# end of file
#
