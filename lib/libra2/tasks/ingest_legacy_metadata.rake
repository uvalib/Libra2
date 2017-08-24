#
# Tasks to manage ingest of legacy Libra metadata
#

# pull in the helpers
require_dependency 'libra2/tasks/ingest_helpers'
include IngestHelpers

namespace :libraetd do

  namespace :ingest do

  #
  # possible environment settings that affect the ingest behavior
  #
  # MAX_COUNT    - Maximum number of items to process
  # DUMP_PAYLOAD - Output the entire document metadata before saving
  # DRY_RUN      - Dont actually create the items
  # NO_WARN      - Suppress warning behavior
  #

  #
  # ingest metadata
  #
  desc "Ingest legacy Libra data; must provide the ingest directory; optionally provide a defaults file, SIS data file, embargo override file and start index"
  task legacy_metadata: :environment do |t, args|

    ingest_dir = ARGV[ 1 ]
    if ingest_dir.nil?
      puts "ERROR: no ingest directory specified, aborting"
      next
    end
    task ingest_dir.to_sym do ; end

    defaults_file = ARGV[ 2 ]
    if defaults_file.nil?
      defaults_file = IngestHelpers::DEFAULT_DEFAULT_FILE
    end
    task defaults_file.to_sym do ; end

    sisdata_file = ARGV[ 3 ]
    if sisdata_file.nil?
      sisdata_file = IngestHelpers::DEFAULT_SIS_DATA_FILE
    end
    task sisdata_file.to_sym do ; end

    embargo_override_file = ARGV[ 4 ]
    if embargo_override_file.nil?
      embargo_override_file = IngestHelpers::DEFAULT_EMBARGO_OVERRIDE_FILE
    end
    task embargo_override_file.to_sym do ; end

    start = ARGV[ 5 ]
    if start.nil?
      start = "0"
    end
    task start.to_sym do ; end

    start_ix = start.to_i
    start_ix = 0 if start_ix.to_s != start

    # get the list of items to be ingested
    ingests = IngestHelpers.get_legacy_ingest_list(ingest_dir )
    if ingests.empty?
      puts "ERROR: ingest directory does not contain contains any items, aborting"
      next
    end

    puts "Loaded #{ingests.length} items for ingest..."

    # load any default attributes
    defaults = IngestHelpers.load_config_file( defaults_file )

    # load the SIS data
    sisdata = IngestHelpers.load_sis_data_file( sisdata_file )
    if sisdata.empty?
      puts "ERROR: SIS datafile does not contain contains any items, aborting"
      next
    end

    puts "Loaded #{sisdata.length} SIS data items..."

    # load the override data
    overridedata = IngestHelpers.load_override_data_file( embargo_override_file )
    if overridedata.empty?
      puts "ERROR: override datafile does not contain contains any items, aborting"
      next
    end

    puts "Loaded #{overridedata.length} override items..."

    # load depositor information
    depositor = Helpers::EtdHelper::lookup_user( IngestHelpers::DEFAULT_DEPOSITOR )
    if depositor.nil?
      puts "ERROR: Cannot locate depositor info (#{IngestHelpers::DEFAULT_DEPOSITOR})"
      next
    end

    user = User.find_by_email( depositor.email )
    if user.nil?
      puts "ERROR: Cannot lookup depositor info (#{depositor.email})"
      next
    end

    success_count = 0
    error_count = 0
    total = ingests.size
    ingests.each_with_index do | dirname, ix |
      next if ix < start_ix
      ok = ingest_legacy_metadata( defaults, sisdata, overridedata,user, File.join( ingest_dir, dirname ), ix + 1, total )
      ok == true ? success_count += 1 : error_count += 1
      break if ENV[ 'MAX_COUNT' ] && ENV[ 'MAX_COUNT' ].to_i == ( success_count + error_count )
    end
    puts "#{success_count} item(s) processed successfully, #{error_count} error(s) encountered"

  end

  #
  # helpers
  #

  #
  # convert a set of Libra extract assets into a new Libra metadata record
  #
  def ingest_legacy_metadata( defaults, sis_data, override_data, depositor, dirname, current, total )

     solr_doc, fedora_doc = IngestHelpers.load_legacy_ingest_content(dirname )
     id = solr_doc['id']

     puts "Ingesting #{current} of #{total}: #{File.basename( dirname )} (#{id})..."

     # create a payload from the document
     payload = create_legacy_ingest_payload( solr_doc, fedora_doc, sis_data, override_data )

     # merge in any default attributes
     payload = apply_defaults_for_legacy_item( defaults, payload )

     # some fields with embedded quotes need to be escaped; handle this here
     payload = IngestHelpers.escape_fields( payload )

     # dump the fields as necessary...
     IngestHelpers.dump_ingest_payload( payload ) if ENV[ 'DUMP_PAYLOAD' ]

     # validate the payload
     errors, warnings = IngestHelpers.validate_ingest_payload( payload )

     if errors.empty? == false
       puts " ERROR(S) identified for #{File.basename( dirname )} (#{id})"
       puts " ==> #{errors.join( "\n ==> " )}"
       return false
     end

     if warnings.empty? == false && ENV['NO_WARN'].nil?
       puts " WARNING(S) identified for #{File.basename( dirname )} (#{id}), continuing anyway"
       puts " ==> #{warnings.join( "\n ==> " )}"
     end

     # handle dry running
     return true if ENV[ 'DRY_RUN' ]

     # create the work
     ok, work = IngestHelpers.create_new_item( depositor, payload )
     if ok == true
       puts "New work created; id #{work.id} (#{work.identifier || 'none'})"
     else
       #puts " ERROR: creating new generic work for #{File.basename( dirname )} (#{id})"
       #return false
       puts " WARNING: while creating generic work for #{File.basename( dirname )} (#{id})"
     end

     # create a record of the actual work id
     if work != nil
        ok = IngestHelpers.set_legacy_ingest_id(dirname, work.id )
        puts " ERROR: creating ingest id file" unless ok
     end

     return ok
  end

  #
  # create a ingest payload from the Libra document
  #
  def create_legacy_ingest_payload( solr_doc, fedora_doc, sis_data, override_data )


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
     payload[ :abstract ] = abstract if IngestHelpers.field_supplied( abstract )

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
     payload[ :advisors ] = []
     advisor_number = 1
     while true
        added, payload[ :advisors ] = add_advisor( solr_doc, advisor_number, payload[ :advisors ] )
        break unless added
        advisor_number += 1
     end

     # issue date
     issued_date = solr_doc.at_path( 'origin_info_date_issued_t[0]' )
     payload[ :issued ] = issued_date if issued_date.present?

     # embargo attributes
     embargo_type = solr_doc.at_path( 'release_to_t[0]' )
     payload[ :embargo_type ] = embargo_type if embargo_type.present?
     release_date = solr_doc.at_path( 'embargo_embargo_release_date_t[0]' )

     # if we find a release date then attempt to convert and apply the embargo
     if release_date.present?

       dt = datetime_from_string( release_date )
       if dt.present?
          payload[ :embargo_release_date ] = dt
          payload[ :embargo_period ] =
             IngestHelpers.estimate_embargo_period( issued_date, release_date ) if issued_date.present?
       end
     end

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

     #
     # special post payload build embargo behavior
     payload = apply_embargo_behavior( sis_data, override_data, payload )

     return payload
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
  #
  #
  def apply_embargo_behavior( sis_data, override_data, payload )

    # check for override information
    if override_data.include? payload[ :source ]
      puts "==> Applying override attributes..."
      payload[ :embargo_type ] = override_data[ payload[ :source ] ]
      payload.delete( :embargo_release_date )
      return payload
    end

    #puts "==> ORIGINAL CREATE DATE: #{payload[ :create_date ]} (#{payload[ :create_date ].class})"
    #puts "==> ISSUED DATE:          #{payload[ :issued ]}"
    #puts "==> EMBARGO TYPE:         #{payload[ :embargo_type ]} (#{payload[ :embargo_type ].class})"
    #puts "==> EMBARGO RELEASE DATE: #{payload[:embargo_release_date]} (#{payload[ :embargo_release_date ].class})"
    #puts "==> EMBARGO PERIOD:       #{payload[:embargo_period]}"

    # if this item is marked as UVa, it is still under embargo with a release date of publish date + 130 years
    if payload[ :embargo_type ] == 'uva'

      # attempt to get a meaningful start date
      dt = datetime_from_string( payload[ :issued ] )
      dt = datetime_from_string( payload[ :create_date ] ) if dt.nil?

      # embargo
      puts "==> UVA work; applying forever rule"
      payload[:embargo_release_date] = dt + 130.years
      payload[ :embargo_type ] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
      return payload
    end


    # if we can determine an embargo release date
    if payload[:embargo_release_date]

      #
      # a special case here.
      # If the embargo release date is within a few days of the create date, we are to treat this as an open
      # item
      #
      cd = datetime_from_string( payload[ :create_date ] )
      duration = ( payload[:embargo_release_date] - cd ).to_i
      if duration.abs <= 5
        puts "==> Embargo duration + or - 5 days or less (#{duration.abs}), identified as open item"
        payload[ :embargo_type ] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        return payload
      end

      #
      # The 'normal' case. A standard embargo item (that may have already expired). Look in SIS to determine if
      # this is an engineering embargo or not.
      #
      if sis_data.include? payload[ :source ]
        if sis_data[ payload[ :source ] ] == 'ENG'
          puts "==> Identified as metadata only work..."
          payload[ :embargo_type ] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        else
          puts "==> Identified as UVA only work..."
          payload[ :embargo_type ] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
        end
      else
        puts "==> Cannot find corresponding SIS record, identified as UVA only work"
        payload[ :embargo_type ] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
      end

    else
      # embargo release date is blank, this must be an open item
      puts "==> No embargo release date, identified as open item"
      payload[ :embargo_type ] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end

    return payload
  end

  #
  # apply any default values and behavior to the standard payload
  #
  def apply_defaults_for_legacy_item( defaults, payload )

    # merge in defaults
    defaults.each { |k, v|

      case k

        when :admin_notes
          next if v.blank?

          # create the admin notes for this item
          original_create_date = payload[ :create_date ]
          time_now = CurationConcerns::TimeService.time_in_utc.strftime( "%Y-%m-%d %H:%M:%S" )
          notes = "#{v.gsub( 'LIBRA1_CREATE_DATE', original_create_date ).gsub( 'CURRENT_DATE', time_now )}"
          payload[ k ] = [ notes ]

          # apply embargo behavior earlier

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

  #
  # attempt to convert a date in the standard format to a date time
  #
  def datetime_from_string( date )
    begin
      return DateTime.strptime( date, '%Y-%m-%d' )
    rescue => ex
      puts "==> EXCEPTION: #{ex} for #{date}"
      return nil
    end
  end


  end   # namespace ingest

end   # namespace libraetd

#
# end of file
#
