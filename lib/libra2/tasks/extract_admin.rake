#
# Some helper tasks to manage data import and export
#

namespace :libra2 do

  namespace :extract do

  MAX_ROWS = 10000
  DEFAULT_QUERY = "*%3A*"
  PRODUCTION_SOLR = "http://libsvr40.lib.virginia.edu:8983/solr/libra/select?wt=json"

  desc "Extract legacy libra data; must provide the work directory"
  task legacy_extract: :environment do |t, args|

    work_dir = ARGV[ 1 ]
    if work_dir.nil?
      puts "ERROR: no work directory specified, aborting"
      next
    end

    task work_dir.to_sym do ; end

    if extract_dir_clean?( work_dir ) == false
      puts "ERROR: work directory already contains extracted items, aborting"
      next
    end

    url = "#{PRODUCTION_SOLR}&rows=#{MAX_ROWS}&q=#{DEFAULT_QUERY}"
    count = 0
    puts "Extracting from SOLR... please wait..."
    response = HTTParty.get( url )
    if response.code == 200

      if response['response'] && response['response']['docs']
        response['response']['docs'].each do |doc|
          export_doc( work_dir, doc, count + 1 )
          count += 1
        end
        puts "#{count} item(s) extracted successfully"
      else
        puts "ERROR: SOLR query returns unexpected response"
      end
    else
      puts "ERROR: SOLR query returns #{response.code}"
    end

  end

  def export_doc( export_dir, work, number )

    puts "exporting document # #{number}..."

    d = File.join( export_dir, "extract.#{number}" )
    FileUtils::mkdir_p( d )

    f = File.join( d, 'data.json' )
    File.open( f, 'w') do |file|
      file.write( work.to_json )
    end

  end

  def extract_dir_clean?( dirname )

    imports = get_extract_list( dirname )
    return imports.empty?

  end

  def get_extract_list( dirname )

    res = []
    begin
      Dir.foreach( dirname ) do |f|
        if /^extract./.match( f )
          res << f
        end
      end
    rescue => e
    end

    return res

  end

end   # namespace extract

end   # namespace libra2

#
# end of file
#
