#
# Some helper tasks to manage data import and export
#

namespace :libra2 do

  namespace :data do

  desc "Bulk export all files and data from libra2; must provide the work directory"
  task bulk_export: :environment do |t, args|

    work_dir = ARGV[ 1 ]
    if work_dir.nil?
      puts "ERROR: no work directory specified, aborting"
      next
    end

    task work_dir.to_sym do ; end

    if export_dir_clean?( work_dir ) == false
      puts "ERROR: work directory already contains exported items, aborting"
      next
    end

    count = 0
    GenericWork.all.each do | work |
      export_work( work_dir, work, count + 1 )
      count += 1
    end

    puts "#{count} items exported successfully"

  end

  desc "Bulk import files and data info libra2; must provide the work directory"
  task bulk_import: :environment do |t, args|

    work_dir = ARGV[ 1 ]
    if work_dir.nil?
      puts "ERROR: no work directory specified, aborting"
      next
    end

    task work_dir.to_sym do ; end

    count = 0
    imports = get_import_list( work_dir )
    imports.each do |f|
      import_work( File.join( work_dir, f ), count + 1 )
      count += 1
    end

    puts "#{count} items exported successfully"

  end

  def export_work( export_dir, work, number )

    puts "exporting work # #{number}..."

    d = File.join( export_dir, "work.#{number}" )
    FileUtils::mkdir_p( d )

    f = File.join( d, 'data.json' )
    File.open( f, 'w') { |file| file.write( work.to_json ) }

    if work.file_sets
      work.file_sets.each do |file_set|
        f = File.join( d, file_set.label )
        get_file( f, file_set.id )
      end

    end
  end

  def import_work( dirname, number )

    puts "importing work # #{number}..."
    f = File.join( dirname, 'data.json' )
    File.open( f, 'r') do |file|
      str = file.readline
      h = JSON.parse( str )
      #puts "[#{h}]"
    end

    filelist = get_file_list( dirname )
    filelist.each do |f|
      puts " uploading #{f}"
    end
  end

  def get_file( filename, id )

    print " getting file #{id}... "

    Net::HTTP.start( 'localhost', 3000 ) do |http|
      resp = http.get("/downloads/#{id}")
      open( filename, "wb" ) do |file|
        file.write( resp.body )
      end
    end
    puts "done"

  end

  def export_dir_clean?( dirname )

    imports = get_import_list( dirname )
    return imports.empty?

  end

  def get_import_list( dirname )

    res = []
    Dir.foreach( dirname ) do |f|
      if /^work./.match( f )
        res << f
      end
    end
    return res

  end

  def get_file_list( dirname )

    res = []
    Dir.foreach( dirname ) do |f|
      if ['.', '..', 'data.json'].include?( f ) == false
        res << f
      end
    end
    return res

  end

  end   # namespace data

end   # namespace libra2

#
# end of file
#
