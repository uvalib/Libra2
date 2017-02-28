#
# Tasks to manage ingest of new metadata
#

# pull in the helpers
require_dependency 'libra2/tasks/ingest_helpers'
include IngestHelpers

namespace :libra2 do

  namespace :ingest do

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
      defaults_file = IngestHelpers::DEFAULT_DEFAULT_FILE
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
    ingests.each_with_index do | filename, ix |
      next if ix < start_ix
      ok = ingest_new_metadata( defaults, user, File.join( ingest_dir, filename ), ix + 1, total )
      ok == true ? success_count += 1 : error_count += 1
      break if ENV[ 'MAX_COUNT' ] && ENV[ 'MAX_COUNT' ].to_i == ( success_count + error_count )
    end
    puts "#{success_count} item(s) processed successfully, #{error_count} error(s) encountered"

  end

  desc "Enumerate newly ingested items"
  task new_list: :environment do |t, args|

    count = 0
    GenericWork.search_in_batches( {} ) do |group|
      group.each do |gw_solr|

        begin
          gw = GenericWork.find( gw_solr['id'] )
          if gw.is_ingested_thesis?
            puts "#{gw.work_source} #{gw.identifier || 'None'}"
            count += 1
          end
        rescue => e
        end

      end

      puts "Listed #{count} ingested work(s)"
    end
  end


  #
  # helpers
  #

  #
  # convert an XML file into a new metadata record
  #
  def ingest_new_metadata( defaults, depositor, filename, current, total )

     xml_doc = IngestHelpers.load_ingest_content( filename )
     #id = solr_doc['id']

     puts "Ingesting #{current} of #{total}: #{filename}..."

     # create a payload from the document
     payload = create_new_ingest_payload( xml_doc )

     # merge in any default attributes
     payload = apply_defaults_for_new_item( defaults, payload )

     # some fields with embedded quotes need to be escaped; handle this here
     payload = IngestHelpers.escape_fields( payload )

     # dump the fields as necessary...
     IngestHelpers.dump_ingest_payload( payload ) if ENV[ 'DUMP_PAYLOAD' ]

     # validate the payload
     errors, warnings = IngestHelpers.validate_ingest_payload( payload )

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
     ok, work = IngestHelpers.create_new_item( depositor, payload )
     if ok == true
       puts "New work created; id #{work.id} (#{work.identifier || 'none'})"
     else
       puts " ERROR: creating new generic work for #{filename}"
       return false
     end

     # create a record of the actual work id
     if work != nil
        ok = IngestHelpers.set_ingest_id( filename, work.id )
        puts " ERROR: creating ingest id file" unless ok
     end

     return ok
  end

  #
  # create a ingest payload from the Libra document
  #
  def create_new_ingest_payload( xml_doc )


     payload = {}

     #
     # add all the required fields
     #

     # creation date
     payload[ :create_date ] = CurationConcerns::TimeService.time_in_utc.strftime( "%Y-%m-%d" )

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
               fn = np.text.chomp( ',' )  # remove a trailing comma
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
     # the space is there for a reason... SOLR stuff, dont ask!!
     payload[ :source ] = "#{GenericWork::THESIS_SOURCE_INGEST} :#{source}" if source.present?

     #
     # handle optional fields
     #

     # degree program
     node = xml_doc.css( 'mods degree level' ).first
     degree = node.text if node
     payload[ :degree ] = degree if degree.present?

     # keywords
     keywords = []
     topic_nodes = xml_doc.css( 'mods topic' )
     topic_nodes.each do |tn|
        kwtext = tn.text
        next if kwtext == 'JTIngest'
        kwords = kwtext.split( ' -- ' )
        kwords.each do |kw|
           w = kw.chomp( ',' )   # remove a trailing comma if present
           keywords << w unless keywords.include?( w )
        end
     end
     payload[ :keywords ] = keywords unless keywords.empty?

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

  private

  #
  # apply any default values and behavior to the standard payload
  #
  def apply_defaults_for_new_item( defaults, payload )

    # merge in defaults
    defaults.each { |k, v|

      case k

        #when :notes
        #  next if v.blank?

          # create the admin notes for this item
        #  new_notes = payload[ :notes ] || ''
        #  new_notes += "\n\n" if new_notes.blank? == false

        #  original_create_date = payload[ :create_date ]
        #  time_now = CurationConcerns::TimeService.time_in_utc.strftime( "%Y-%m-%d %H:%M:%S" )
        #  new_notes += "#{v.gsub( 'LIBRA1_CREATE_DATE', original_create_date ).gsub( 'CURRENT_DATE', time_now )}"
        #  payload[ :notes ] = new_notes

        when :default_embargo_type
          if payload[ :embargo_type ].blank?
            payload[ :embargo_type ] = v
          end

        when :force_embargo_period
           payload[ :embargo_period ] = v
           if payload[ :issued ]
              payload[ :embargo_release_date ] = IngestHelpers.calculate_embargo_release_date( payload[ :issued ], v )
           else
              payload[ :embargo_release_date ] = GenericWork.calculate_embargo_release_date( v )
           end

        else
           if payload.key?( k ) == false
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
