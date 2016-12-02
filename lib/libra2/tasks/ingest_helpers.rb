#
# Helpers for the ingest process
#

include ERB::Util

module IngestHelpers

  #
  # get the list of Libra extract items from the work directory
  #
  def get_ingest_list( dirname )
    return TaskHelpers.get_directory_list( dirname, /^extract./ )
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
  # Locate elsewhere later
  #
  def department_lookup( department )

    case department
      when 'Civil & Env Engr'
        return 'Department of Civil Engineering'
    end
    return department
  end

  #
  # determine if a field is provided; look for the special valuye 'None Provided'
  #
  def field_supplied( field )
    return false if field.blank?
    return false if field == 'None Provided'
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