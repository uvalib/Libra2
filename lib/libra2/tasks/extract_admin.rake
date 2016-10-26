#
# Tasks to manage legacy Libra export
#

require 'oga'

namespace :libra2 do

  namespace :extract do

  # SOLR extract attributes
  DEFAULT_MAX_SOLR_ROWS = "100"
  DEFAULT_SOLR_QUERY_FILE = "data/default_solr_query.txt"
  PRODUCTION_SOLR = "http://libsvr40.lib.virginia.edu:8983/solr/libra/select?wt=json"

  # Libra extract attributes
  PRODUCTION_LIBRA = "http://libraprod.lib.virginia.edu"

  #
  # extract items from SOLR according to the query file and maximum number of rows
  #
  desc "Extract SOLR Libra data; must provide the extract directory; optionally provide query file and max rows"
  task solr_extract: :environment do |t, args|

    work_dir = ARGV[ 1 ]
    if work_dir.nil?
      puts "ERROR: no extract directory specified, aborting"
      next
    end
    task work_dir.to_sym do ; end

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

    if solr_dir_clean?( work_dir ) == false
      puts "ERROR: extract directory already contains SOLR items, aborting"
      next
    end

    query = load_solr_query( query_file )
    if query.blank?
      puts "ERROR: query file is empty, aborting"
      next
    end

    url = "#{PRODUCTION_SOLR}&rows=#{max_rows}&q=#{query}"
    count = 0
    puts "Extracting up to #{max_rows} records from SOLR... please wait..."
    response = HTTParty.get( url )
    if response.code == 200

      if response['response'] && response['response']['docs']
        response['response']['docs'].each do |doc|
          dump_solr_doc( work_dir, doc, count + 1 )
          count += 1
        end
        puts "#{count} item(s) extracted successfully"
      else
        puts "ERROR: SOLR query returns unexpected response"
      end
    else
      puts "ERROR: SOLR query returns #{response.code} for #{url}"
    end

  end

  #
  # Process the extracted SOLR documents and generate the extracted Libra items
  #
  desc "Process SOLR Libra data; must provide the extract directory and results directory"
  task solr_process: :environment do |t, args|

    work_dir = ARGV[ 1 ]
    if work_dir.nil?
      puts "ERROR: no extract directory specified, aborting"
      next
    end

    task work_dir.to_sym do ; end

    results_dir = ARGV[ 2 ]
    if results_dir.nil?
      puts "ERROR: no results directory specified, aborting"
      next
    end

    task results_dir.to_sym do ; end

    if libra_dir_clean?( results_dir ) == false
      puts "ERROR: results directory is not empty, aborting"
      next
    end

    items = get_solr_extract_list( work_dir )
    if items.empty?
      puts "ERROR: extract directory does not contain contains SOLR items, aborting"
      next
    end

    count = 0
    items.each do | dirname |
      f = File.join( work_dir, dirname )
      process_solr_doc( results_dir, f, count + 1 )
      count += 1
    end
    puts "#{count} item(s) processed successfully"

  end

  #
  # process the Libra extracts and pull any specified file assets
  #
  desc "Extract Libra file assets; must provide the extract directory"
  task asset_extract: :environment do |t, args|

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

    count = 0
    dirname.each do | dirname |
      extract_any_assets( File.join( work_dir, dirname ) )
      count += 1
    end
    puts "#{count} item(s) processed successfully"

  end

  #
  # helpers
  #

  #
  # extract any file assets from Libra
  #
  def extract_any_assets( dirname )

    puts "processing #{dirname}..."

    f = File.join( dirname, TaskHelpers::DOCUMENT_HTML_FILE )
    handle = File.open( f )
    document = Oga.parse_html( handle )
    handle.close( )

    assets = document.css( '.file_asset a' )
    assets.each do |asset|
      download_libra_asset( asset['href'], File.join( dirname, asset.text ) )
    end

    f = File.join( dirname, TaskHelpers::DOCUMENT_FILES_LIST )
    File.open( f, 'w') do |file|
      assets.each do |asset|
         file.write( "#{asset.text}:#{asset.text}\n" )
      end
    end
  end

  #
  # write the extracted SOLR document
  #
  def dump_solr_doc( export_dir, doc, number )

    puts "writing SOLR document # #{number}..."

    d = File.join( export_dir, "solr.#{number}" )
    FileUtils::mkdir_p( d )

    f = File.join( d, TaskHelpers::DOCUMENT_JSON_FILE )
    File.open( f, 'w') do |file|
      file.write( doc.to_json )
    end

  end

  #
  # extract the Libra document given its id
  #
  def extract_libra_doc( results_dir, number, id )

    puts "extracting #{id} from Libra..."

    url = "#{PRODUCTION_LIBRA}/catalog/#{id}"
    html_response = HTTParty.get( url )
    if html_response.code == 200
      url = "#{url}.json"
      json_response = HTTParty.get( url )
      if json_response.code == 200
         dump_libra_doc( results_dir, number, id, html_response, json_response )
      else
        puts "ERROR: Libra query returns #{json_response.code} for #{url}"
      end
    else
      puts "ERROR: Libra query returns #{html_response.code} for #{url}"
    end

  end

  #
  # write the extracted Libra document
  #
  def dump_libra_doc( export_dir, number, id, html, json )

    puts "writing Libra document # #{number}..."

    d = File.join( export_dir, "libra.#{number}" )
    FileUtils::mkdir_p( d )

    f = File.join( d, TaskHelpers::DOCUMENT_ID_FILE )
    File.open( f, 'w') do |file|
      file.write( "{\"id\":\"#{id}\"}" )
    end

    f = File.join( d, TaskHelpers::DOCUMENT_HTML_FILE )
    File.open( f, 'w') do |file|
      file.write( html )
    end

    f = File.join( d, TaskHelpers::DOCUMENT_JSON_FILE )
    File.open( f, 'w') do |file|
      file.write( json.to_json )
    end

  end

  #
  # process the SOLR document
  #
  def process_solr_doc( results_dir, source_file, number )

    puts "processing SOLR document # #{File.basename( source_file )}..."

    f = File.join( source_file, TaskHelpers::DOCUMENT_JSON_FILE )
    File.open( f, 'r') do |file|
      json_str = file.read( )
      doc = JSON.parse json_str
      libra_id = doc['id']
      extract_libra_doc( results_dir, number, libra_id )
    end

  end

  #
  # download the specified asset from Libra
  #
  def download_libra_asset( asset_href, filename )

    url = "#{PRODUCTION_LIBRA}#{asset_href}"
    puts " downloading #{File.basename( filename )}..."

    File.open( filename, "wb" ) do |f|
      f.binmode
      f.write HTTParty.get( url ).parsed_response
      f.close
    end

  end

  #
  # check to ensure if the SOLR extract directory is empty
  #
  def solr_dir_clean?( dirname )
    items = get_solr_extract_list( dirname )
    return items.empty?
  end

  #
  # check to ensure if the Libra extract directory is empty
  #
  def libra_dir_clean?( dirname )
    items = get_libra_extract_list( dirname )
    return items.empty?
  end

  #
  # check to ensure if the work directory is empty
  #
  def work_dir_clean?( dirname )
    items = get_work_list( dirname )
    return items.empty?
  end

  #
  # get the list of SOLR extract items from the work directory
  #
  def get_solr_extract_list( dirname )
    return TaskHelpers.get_directory_list( dirname, /^solr./ )
  end

  #
  # get the list of Libra extract items from the work directory
  #
  def get_libra_extract_list( dirname )
    return TaskHelpers.get_directory_list( dirname, /^libra./ )
  end

  #
  # get the list of items from the work directory
  #
  def get_work_list( dirname )
    return TaskHelpers.get_directory_list( dirname, /^work./ )
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
