#
# Helpers for the ingest process
#

include ERB::Util

module IngestHelpers

  DEFAULT_DEPOSITOR = TaskHelpers::DEFAULT_USER
  DEFAULT_DEFAULT_FILE = 'data/default_ingest_attributes.yml'
  MAX_ABSTRACT_LENGTH = 32766

  # mapping of department names/mnemonics to actual textual values
  DEPARTMENT_MAP = {
      'ADMIN-EDD' => 'Curry School of Education',
      'ADMIN-MED' => 'Curry School of Education',
      'ANTHRO-PHD' => 'Department of Anthropology',
      'ARCH-MAR' => 'Department of Architectural History',
      'ARH-MARH' => 'Department of Architectural History',
      'ARTARC-MA' => 'Department of Art',
      'ARTARC-PHD' => 'Department of Art',
      'ASTRON-PHD' => 'Department of Astronomy',
      'BIOL-MA' => 'Department of Biology',
      'BIOL-MS' => 'Department of Biology',
      'BIOL-PHD' => 'Department of Biology',
      'BIOMEN-ME' => 'Department of Biomedical Engineering',
      'BIOMEN-MS' => 'Department of Biomedical Engineering',
      'BIOMEN-PHD' => 'Department of Biomedical Engineering',
      'BIOMOL-PHD' => 'Department of Biochemistry and Molecular Genetics',
      'BIOP-PHD' => 'Department of Biophysics',
      'CELL-PHD' => 'Department of Molecular, Cell and Developmental Biology',
      'CHEM-MS' => 'Department of Chemistry',
      'CHEM-PHD' => 'Department of Chemistry',
      'CHEMEN-CGE' => 'Department of Chemical Engineering',
      'CHEMEN-ME' => 'Department of Chemical Engineering',
      'CHEMEN-MS' => 'Department of Chemical Engineering',
      'CHEMEN-PHD' => 'Department of Chemical Engineering',
      'CIVIL-CGE' => 'Department of Civil Engineering',
      'CIVIL-ME' => 'Department of Civil Engineering',
      'CIVIL-MS' => 'Department of Civil Engineering',
      'CIVIL-PHD' => 'Department of Civil Engineering',
      'CLAS-PHD' => 'Department of Classics',
      'CLNPSY-PHD' => 'Curry School of Education',
      'COMPEN-ME' => 'Department of Computer Engineering',
      'COMPEN-MS' => 'Department of Computer Engineering',
      'COMPEN-PHD' => 'Department of Computer Engineering',
      'COMPSC-MCS' => 'Department of Computer Science',
      'COMPSC-MS' => 'Department of Computer Science',
      'COMPSC-PHD' => 'Department of Computer Science',
      'COUNS-EDD' => 'Curry School of Education',
      'COUNS-MED' => 'Curry School of Education',
      'CURRIN-EDD' => 'Curry School of Education',
      'CURRIN-MED' => 'Curry School of Education',
      'Civil & Env Engr' => 'Department of Civil Engineering',
      'DRAMA-MFA' => 'Department of Drama',
      'EASIAN-MA' => 'Department of East Asian Studies',
      'ECON-PHD' => 'Department of Economics',
      'EDPSYC-EDD' => 'Curry School of Education',
      'EDPSYC-MED' => 'Curry School of Education',
      'EDUC-PHD' => 'Curry School of Education',
      'ELECT-CGE' => 'Department of Electrical Engineering',
      'ELECT-ME' => 'Department of Electrical Engineering',
      'ELECT-MS' => 'Department of Electrical Engineering',
      'ELECT-PHD' => 'Department of Electrical Engineering',
      'ENGL-MA' => 'Department of English',
      'ENGL-PHD' => 'Department of English',
      'ENGPHY-CGE' => 'Department of Engineering Physics',
      'ENGPHY-MEP' => 'Department of Engineering Physics',
      'ENGPHY-MS' => 'Department of Engineering Physics',
      'ENGPHY-PHD' => 'Department of Engineering Physics',
      'EVSC-MA' => 'Department of Environmental Sciences',
      'EVSC-MS' => 'Department of Environmental Sciences',
      'EVSC-PHD' => 'Department of Environmental Sciences',
      'EXPATH-PHD' => 'Department of Pathology',
      'FORAFF-MA' => 'Department of Foreign Affairs',
      'FORAFF-PHD' => 'Department of Politics',
      'FRENCH-PHD' => 'Department of French',
      'GERMAN-MS' => 'Department of Germanic Languages and Literatures',
      'GERMAN-PHD' => 'Department of Germanic Languages and Literatures',
      'GOVT-MA' => 'Department of Politics',
      'GOVT-PHD' => 'Department of Politics',
      'HIGHED-EDD' => 'Curry School of Education',
      'HIGHED-MED' => 'Curry School of Education',
      'HIST-MA' => 'Department of History',
      'HIST-PHD' => 'Department of History',
      'ITAL-MA' => 'Department of Spanish, Italian, and Portuguese',
      'KINES-MED' => 'Curry School of Education',
      'MAE-CGE' => 'Department of Mechanical and Aerospace Engineering',
      'MAE-ME' => 'Department of Mechanical and Aerospace Engineering',
      'MAE-MS' => 'Department of Mechanical and Aerospace Engineering',
      'MAE-PHD' => 'Department of Mechanical and Aerospace Engineering',
      'MATH-PHD' => 'Department of Mathematics',
      'MATSC-CGE' => 'Department of Materials Science and Engineering',
      'MATSC-MMSE' => 'Department of Materials Science and Engineering',
      'MATSCI-MS' => 'Department of Materials Science and Engineering',
      'MATSCI-PHD' => 'Department of Materials Science and Engineering',
      'MICRO-PHD' => 'Department of Microbiology, Immunology, and Cancer Biology',
      'MUSIC-PHD' => 'Department of Music',
      'NEURO-PHD' => 'Department of Neuroscience',
      'NURS-DNP' => 'School of Nursing',
      'NURS-PHD' => 'School of Nursing',
      'PHARM-PHD' => 'Department of Pharmacology',
      'PHIL-PHD' => 'Department of Philosophy',
      'PHY-PHD' => 'Department of Molecular Physiology and Biological Physics',
      'PHYS-MS' => 'Department of Physics',
      'PHYS-PHD' => 'Department of Physics',
      'PLAN-MUEP' => 'Department of Urban and Environmental Planning',
      'PSYCH-MA' => 'Department of Psychology',
      'PSYCH-PHD' => 'Department of Psychology',
      'RELIG-MA' => 'Department of Religious Studies',
      'RELIG-PHD' => 'Department of Religious Studies',
      'SLAVIC-MA' => 'Department of Slavic Languages and Literatures',
      'SLAVIC-PHD' => 'Department of Slavic Languages and Literatures',
      'SOCIOL-MA' => 'Department of Sociology',
      'SOCIOL-PHD' => 'Department of Sociology',
      'SPAN-PHD' => 'Department of Spanish, Italian, and Portuguese',
      'SPATH-MED' => 'Curry School of Education',
      'SPCED-MED' => 'Curry School of Education',
      'STATS-PHD' => 'Department of Statistics',
      'SYSTEM-AM' => 'Department of Systems Engineering',
      'SYSTEM-CGE' => 'Department of Systems Engineering',
      'SYSTEM-ME' => 'Department of Systems Engineering',
      'SYSTEM-MS' => 'Department of Systems Engineering',
      'SYSTEM-PHD' => 'Department of Systems Engineering',
      'University of Virginia Libraries' => 'University of Virginia Library',
      'WRITE-MFA' => 'Department of English'
  }

  # various placeholders that have been used to indicate that a field was not provided
  BLANK_PLACEHOLDERS = [
      'None Provided',
      'None Providedd', # found in the data
      'None Found',
      'None',
      'none',
      'not available',
      'No Abstract Found',
      'No abstract available',
      'No abstract found'
  ]

  #
  # validate the payload before we attempt to create a new work
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
    #errors << 'missing author first name' if payload[ :author_first_name ].nil?
    #errors << 'missing author last name' if payload[ :author_last_name ].nil?

    # other required attributes
    errors << 'missing rights' if payload[ :rights ].nil?
    errors << 'missing publisher' if payload[ :publisher ].nil?
    errors << 'missing institution' if payload[ :institution ].nil?
    errors << 'missing source' if payload[ :source ].nil?
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

    # author attributes
    warnings << 'missing author first name' if payload[ :author_first_name ].nil?
    warnings << 'missing author last name' if payload[ :author_last_name ].nil?
    warnings << 'missing author computing id' if payload[ :author_computing_id ].nil?

    warnings << 'missing advisor(s)' if payload[ :advisors ].blank?

    warnings << 'missing issued date' if payload[ :issued ].nil?
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
  # get the list of new items from the work directory
  #
  def get_ingest_list( dirname )
    return TaskHelpers.get_directory_list( dirname, /^.*\.xml$/ )
  end

  #
  # load the XML document from the specified file
  #
  def load_ingest_content( filename )
    xml_doc = TaskHelpers.load_xml_doc( filename )
    return xml_doc
  end

  #
  # get the list of Libra extract items from the work directory
  #
  def get_legacy_ingest_list(dirname )
    return TaskHelpers.get_directory_list( dirname, /^extract./ )
  end

  #
  # load the Libra data from the specified directory
  #
  def load_legacy_ingest_content(dirname )
    json_doc = TaskHelpers.load_json_doc( File.join( dirname, TaskHelpers::DOCUMENT_JSON_FILE ) )
    xml_doc = TaskHelpers.load_xml_doc( File.join( dirname, TaskHelpers::DOCUMENT_XML_FILE ) )
    return json_doc, xml_doc
  end

  #
  # load the hash of default attributes
  #
  def load_config_file( filename )

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

  #
  # list any assets that go with the document
  #
  def get_document_assets( dirname )

    files = []
    f = File.join( dirname, TaskHelpers::DOCUMENT_FILES_LIST )
    begin
      File.open( f, 'r').each do |line|

        # handle blank and commented lines
        next if line.blank?
        next if line[ 0 ] == '#'
        tokens = line.strip.split( "|" )
        files << { :id => tokens[ 0 ], :timestamp => tokens[ 1 ], :title => tokens[ 2 ] }
      end
    rescue Errno::ENOENT
      # do nothing, no files...
    end

    return files
  end

  #
  # get the ingest id from the file
  #
  def get_legacy_ingest_id( dirname )

    f = File.join( dirname, TaskHelpers::INGEST_ID_FILE )
    File.open( f, 'r') do |file|
      id = file.read( )
      return id
    end
  end

  #
  # write the ingest id to the file
  #
  def set_legacy_ingest_id( dirname, id )

    f = File.join( dirname, TaskHelpers::INGEST_ID_FILE )
    File.open( f, 'w') do |file|
      file.write( id )
    end
  end

  #
  # remove the ingest id file
  #
  def clear_legacy_ingest_id( dirname )

    begin
      f = File.join( dirname, TaskHelpers::INGEST_ID_FILE )
      File.delete( f )
    rescue => e
    end
  end


  #
  # get the ingest id from the file
  #
  def get_ingest_id( filename )

     begin
        File.open( "#{filename}.id", 'r') do |file|
           id = file.read( )
           return id
        end
     rescue => e
     end
     return ''
  end

  #
  # write the ingest id to the file
  #
  def set_ingest_id( filename, id )

    begin
       File.open( "#{filename}.id", 'w') do |file|
          file.write( id )
       end
       return true
    rescue => e
    end
    return false
  end

  #
  # remove the ingest id file
  #
  def clear_ingest_id( filename )

    begin
      File.delete( "#{filename}.id" )
      return true
    rescue => e
    end
    return false
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
  # simple payload dump for debugging
  #
  def dump_ingest_payload( payload )
    puts '*' * 80
    payload.each { |k, v|
      puts " ==> #{k} -> #{v}"
    }
    puts '*' * 80
  end

  #
  # add the specified number of years to the specified date
  #
  def calculate_embargo_release_date( date, embargo_period )

    normalized_date = normalize_date( date )
    dt = Date.parse( normalized_date )
    case embargo_period
      when GenericWork::EMBARGO_VALUE_6_MONTH
        return dt + 6.months
      when GenericWork::EMBARGO_VALUE_1_YEAR
        return dt + 1.year
      when GenericWork::EMBARGO_VALUE_2_YEAR
        return dt + 2.years
      when GenericWork::EMBARGO_VALUE_5_YEAR
        return dt + 5.years
      when GenericWork::EMBARGO_VALUE_FOREVER
        return dt + 130.years
    end
    return dt
  end

  #
  # calculate the approx original embargo period given the issued and release dates
  #
  def estimate_embargo_period( issued, embargo_release )
    period = Date.parse( embargo_release ) - Date.parse( issued )
    case period.to_i
      when 0
        return ''
      when 1..186
        return GenericWork::EMBARGO_VALUE_6_MONTH
      when 187..366
        return GenericWork::EMBARGO_VALUE_1_YEAR
      when 367..731
        return GenericWork::EMBARGO_VALUE_2_YEAR
      when 732..1825
        return GenericWork::EMBARGO_VALUE_5_YEAR
      else
        return GenericWork::EMBARGO_VALUE_FOREVER
    end
  end

  #
  # attempt to return a date in YYYY-MM-DD, filling in the missing pieces if we do not have them
  #
  def normalize_date( date )

    # look for the expected pattern (YYYY-MM-DD)
    matches = /^(\d{4}-\d{2}-\d{2})/.match( date )
    return matches[ 1 ] if matches

    # look for YYYY-MM and append '-01' if we find it
    matches = /^(\d{4}-\d{2})/.match( date )
    return "#{matches[ 1 ]}-01" if matches

    # look for YYYY and append '-01-01' if we find it
    matches = /^(\d{4})/.match( date )
    return "#{matches[ 1 ]}-01-01" if matches

    # give up and return what we were provided
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
  # looks up the language name from the language code
  # Locate elsewhere later
  #
  def language_code_lookup( language_code )

    case language_code
      when 'eng'
        return 'English'
      when 'fre'
        return 'French'
      when 'ger'
        return 'German'
      when 'spa'
        return 'Spainish'
    end
    return language_code
  end

  #
  # maps department name from L1 to L2
  #
  def department_lookup( department )
    return DEPARTMENT_MAP[ department ] if DEPARTMENT_MAP.key? ( department )
    return department
  end

  #
  # determine if a field is provided; look for special values... this sux
  #
  def field_supplied( field )
    return false if field.blank?
    return false if BLANK_PLACEHOLDERS.include?( field )
    return true
  end

  #
  # escape any fields in the payload that require it
  #
  def escape_fields( payload )

    payload[:title] = escape_field( payload[:title] ) if field_supplied( payload[:title] )
    payload[:abstract] = escape_field( payload[:abstract] ) if field_supplied( payload[:abstract] )
    return payload

  end

  #
  # escape special characters as necessary
  #
  def escape_field( field )
    return html_escape( field ).gsub( "\\", "\\\\\\" )
  end


end

#
# end of file
#