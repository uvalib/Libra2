#
# Tasks to manage legacy Libra export
#

namespace :libra2 do

  namespace :extract do

  # SOLR extract attributes
  DEFAULT_MAX_SOLR_ROWS = "100"
  DEFAULT_SOLR_QUERY_FILE = "data/solr_query/default_solr_query.txt"
  PRODUCTION_SOLR = "http://localhost:9000/solr/development/select?wt=json"
  PRODUCTION_FEDORA = "http://fedoraAdmin:fedoraAdmin@localhost:9000/fedora/objects"

  #
  # extract items from SOLR according to the query file and maximum number of rows
  #
  desc "Extract SOLR Libra data; must provide the extract directory; optionally provide query file and max rows"
  task solr_extract: :environment do |t, args|

    extract_dir = ARGV[ 1 ]
    if extract_dir.nil?
      puts "ERROR: no extract directory specified, aborting"
      next
    end
    task extract_dir.to_sym do ; end

    query_file = ARGV[ 2 ]
    if query_file.nil?
      query_file = DEFAULT_SOLR_QUERY_FILE
    end
    task query_file.to_sym do ; end

    max_rows = ARGV[ 3 ]
    if max_rows.nil?
      max_rows = DEFAULT_MAX_SOLR_ROWS
    end
    task max_rows.to_sym do ; end

    if extract_dir_clean?(extract_dir ) == false
      puts "ERROR: extract directory already contains items, aborting"
      next
    end

    query = load_solr_query( query_file )
    if query.blank?
      puts "ERROR: query file is empty, aborting"
      next
    end

    url = "#{PRODUCTION_SOLR}&rows=#{max_rows}&q=#{query}"
    success_count = 0
    error_count = 0

    puts "Extracting up to #{max_rows} records from SOLR... please wait..."
    response = HTTParty.get( url )
    if response.code == 200

      # turn into real JSON
      response = JSON.parse( response )

      if response['response'] && response['response']['docs']
        response['response']['docs'].each_with_index do |doc, ix|
          ok = process_solr_doc(extract_dir, doc, ix + 1 )
          ok == true ? success_count += 1 : error_count += 1
        end
        puts "#{success_count} item(s) extracted successfully, #{error_count} error(s) encountered; results in #{extract_dir}"
      else
        puts "ERROR: SOLR query returns unexpected response, aborting"
      end
    else
      puts "ERROR: SOLR query returns #{response.code} for #{url}, aborting"
    end

  end

  #
  # process the Libra extracts and pull any specified file assets
  #
  desc "Extract Fedora file assets; must provide the extract directory and file asset directory; optionally provide starting index"
  task asset_extract: :environment do |t, args|

    extract_dir = ARGV[ 1 ]
    if extract_dir.nil?
      puts "ERROR: no extract directory specified, aborting"
      next
    end

    task extract_dir.to_sym do ; end

    asset_dir = ARGV[ 2 ]
    if asset_dir.nil?
      puts "ERROR: no asset directory specified, aborting"
      next
    end

    task asset_dir.to_sym do ; end

    start = ARGV[ 3 ]
    start_ix = 0
    if start.nil? == false
      start_ix = start.to_i
      task start.to_sym do ; end
    end

    extracts = get_extract_list( extract_dir )
    if extracts.empty?
      puts "ERROR: extract directory does not contain contains any items, aborting"
      next
    end

    assets = get_extract_list( asset_dir )
    if assets.empty?
      puts "ERROR: asset directory does not contain contains any items, aborting"
      next
    end

    asset_refs = load_asset_references( asset_dir, assets )

    success_count = 0
    error_count = 0
    extracts.each_with_index do | dirname, ix |
      next if ix < start_ix
      ok = extract_any_assets( asset_refs, File.join( extract_dir, dirname ) )
      ok == true ? success_count += 1 : error_count += 1
    end
    puts "#{success_count} item(s) processed successfully, #{error_count} error(s) encountered; results in #{extract_dir}"

  end

  #
  # helpers
  #

  #
  # load the file asset reference list
  #
  def load_asset_references( asset_dir, assets )

    count = 0
    asset_refs = {}
    puts "Loading file asset references..."
    assets.each do | dirname |
      doc = TaskHelpers.load_json_doc( File.join( asset_dir, dirname, TaskHelpers::DOCUMENT_JSON_FILE ) )

      if doc[ 'id' ] && doc[ 'is_part_of_s' ] && doc[ 'system_create_dt' ] && doc[ 'title_t' ]
        doc[ 'is_part_of_s' ].each { |d|
            id = doc[ 'id' ]
            ts = doc[ 'system_create_dt' ]
            title = doc[ 'title_t' ][ 0 ]
            po = File.basename( d )
            if asset_refs.key?( po ) == false
              asset_refs[ po ] = []
            end
            asset_refs[ po ] << { :id => id, :create_date => ts, :title => title }
        }
      end
      count += 1
    end

    puts "#{count} file assets loaded..."
    return asset_refs
  end

  #
  # extract any file assets from Libra
  #
  def extract_any_assets( asset_refs, dirname )

    ok = true
    puts "processing #{dirname}..."

    json = TaskHelpers.load_json_doc( File.join( dirname, TaskHelpers::DOCUMENT_JSON_FILE ) )
    id = json[ 'id' ]
    fname = File.join( dirname, TaskHelpers::DOCUMENT_FILES_LIST )
    f = File.new( fname, 'w:ASCII-8BIT' )
    if asset_refs.key?( id )
      asset_refs[id].each { |asset|
        ok = download_fedora_file( asset[ :id ], File.join( dirname, asset[ :title ] ) )
        f.write( "#{asset[ :id ]}|#{asset[ :create_date ]}|#{asset[ :title ]}\n" ) if ok
      }

    end
    f.close( )
    return ok
  end

  #
  # process the extracted SOLR document
  #
  def process_solr_doc( export_dir, doc, number )

    puts " writing SOLR document # #{number} (#{doc['id']})..."

    d = File.join( export_dir, "extract.#{number}" )
    FileUtils::mkdir_p( d )

    f = File.join( d, TaskHelpers::DOCUMENT_JSON_FILE )
    File.open( f, 'w') do |file|
      file.write( JSON.pretty_generate( doc ) )
    end

    # download the fedora representation too
    f = File.join( d, TaskHelpers::DOCUMENT_XML_FILE )
    return( download_fedora_metadata( doc['id'], f ) )
  end

  #
  # download the specified file from Fedora and write it to a file
  #
  def download_fedora_file( asset_id, filename )
    return( download_fedora_asset( "#{PRODUCTION_FEDORA}/#{asset_id}/datastreams/DS1/content", filename ) )
  end

  #
  # download the specified metadata from Fedora and write it to a file
  #
  def download_fedora_metadata( asset_id, filename )
    return( download_fedora_asset( "#{PRODUCTION_FEDORA}/#{asset_id}/datastreams/descMetadata/content", filename ) )
  end

  #
  # download the specified object from Fedora and write it to a file
  #
  #def download_fedora_object( asset_id, filename )
  #  return( download_fedora_asset( "#{PRODUCTION_FEDORA}/#{asset_id}/objectXML", filename ) )
  #end

  #
  # download the specified asset from Fedora and write it to a file
  #
  def download_fedora_asset( url, filename )

    puts " downloading Fedora asset -> #{filename} ..."
    #puts "    URL -> #{url}"

    ok = true
    File.open( filename, 'wb' ) do |f|
      f.binmode
      response = HTTParty.get( url )
      if response.code == 200
         f.write( response.body )
      else
        ok = false
      end

      #HTTParty.get( url, :debug_output => f ) #.parsed_response
      f.close
    end

    return ok
  end

  #
  # check to ensure if the SOLR extract directory is empty
  #
  def extract_dir_clean?(dirname )
    items = get_extract_list(dirname )
    return items.empty?
  end

  #
  # get the list of SOLR extract items from the work directory
  #
  def get_extract_list(dirname )
    return TaskHelpers.get_directory_list( dirname, /^extract./ )
  end

  #
  # load the contents of the specified SOLR query file
  #
  def load_solr_query( file )

    File.open( file, 'r') do |file|
      query_str = file.read( )
      return query_str
    end
  end

  end   # namespace extract

end   # namespace libra2

#
# end of file
#
