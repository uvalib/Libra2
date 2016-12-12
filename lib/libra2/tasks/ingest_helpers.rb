#
# Helpers for the ingest process
#

include ERB::Util

module IngestHelpers

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
      'No abstract available'
  ]
  #
  # get the list of Libra extract items from the work directory
  #
  def get_ingest_list( dirname )
    return TaskHelpers.get_directory_list( dirname, /^extract./ )
  end

  #
  # load the Libra data from the specified directory
  #
  def load_ingest_content(dirname )
    json_doc = TaskHelpers.load_json_doc( File.join( dirname, TaskHelpers::DOCUMENT_JSON_FILE ) )
    xml_doc = TaskHelpers.load_xml_doc( File.join( dirname, TaskHelpers::DOCUMENT_XML_FILE ) )
    return json_doc, xml_doc
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
    dt = Date.parse( date )
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