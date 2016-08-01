#
# Some helper tasks to manage data import and export
#

namespace :libra2 do

  namespace :data do

  desc "Bulk export all files and data from libra2; must provide the work directory and optional hostname/port"
  task bulk_export: :environment do |t, args|

    work_dir = ARGV[ 1 ]
    if work_dir.nil?
      puts "ERROR: no work directory specified, aborting"
      next
    end

    task work_dir.to_sym do ; end

    endpoint = ARGV[ 2 ]
    if endpoint.nil?
      endpoint = 'localhost:3000'
    end

    task endpoint.to_sym do ; end

    if export_dir_clean?( work_dir ) == false
      puts "ERROR: work directory already contains exported items, aborting"
      next
    end

    count = 0
    GenericWork.all.each do | work |
      export_work( endpoint, work_dir, work, count + 1 )
      count += 1
    end

    puts "#{count} item(s) exported successfully"

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

    puts "#{count} item(s) imported successfully"

  end

  def export_work( endpoint, export_dir, work, number )

    puts "exporting work # #{number}..."

    d = File.join( export_dir, "work.#{number}" )
    FileUtils::mkdir_p( d )

    f = File.join( d, 'data.json' )
    File.open( f, 'w') do |file|
      file.write( work.to_json )
    end

    f = File.join( d, 'special.txt' )
    File.open( f, 'w') do |file|
      file.write( "visibility: #{work.visibility}\n" )
    end

    if work.file_sets && work.file_sets.length != 0

       f = File.join( d, 'filelist.txt' )
       File.open( f, 'w') do |file|
          work.file_sets.each do |file_set|
             #puts file_set.inspect
             file.write( "#{file_set.label}:#{file_set.title[0]}\n" )
          end
       end

       work.file_sets.each do |file_set|
         f = File.join( d, file_set.label )
         get_file( endpoint, f, file_set.label, file_set.id )
       end

    end
  end

  def import_work( dirname, number )

    puts "importing work # #{number}..."
    h = {}
    f = File.join( dirname, 'data.json' )
    File.open( f, 'r') do |file|
      str = file.readline
      h = JSON.parse( str )
      #puts "[#{h}]"
    end

    # lookup user and exit if error
    user = User.find_by_email( h['depositor'] )
    if user.nil?
      puts "ERROR: locating user #{h['depositor']}, aborting"
      return
    end

    work = make_new_work( user, h )

    f = File.join( dirname, 'special.txt' )
    File.open( f, 'r').each do |line|

      line = line.strip
      if /^visibility/.match( line )
        work.visibility = line.gsub( "visibility: ", "" )
      end
    end

    work.save!

    filelist = get_file_list( dirname )
    filelist.each do |f|
      TaskHelpers.upload_file( user, work, File.join( dirname, f[ :filename ] ), f[ :label ] )
    end
  end

  def get_file( endpoint, filename, label, id )

    print " getting file #{label} from #{endpoint}... "

    host = endpoint.split( ":" )[ 0 ]
    port = endpoint.split( ":" )[ 1 ]
    port = port.to_i
    Net::HTTP.start( host, port ) do |http|
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
    begin
      Dir.foreach( dirname ) do |f|
        if /^work./.match( f )
          res << f
        end
      end
    rescue => e
    end

    return res

  end

  def get_file_list( dirname )

    res = []
    begin
      f = File.join( dirname, 'filelist.txt' )
      File.open( f, 'r').each do |line|
        tokens = line.strip.split( ":" )
        res << { :filename => tokens[ 0 ], :label => tokens[ 1 ] }
      end
    rescue => e
    end

    return res

  end

  def make_new_work( user, h )

    work = GenericWork.create!(title: h['title'] ) do |w|

      # generic work attributes
      w.apply_depositor_metadata( user )
      w.creator = h['creator']
      w.author_email = h['author_email']
      w.author_first_name = h['author_first_name']
      w.author_last_name = h['author_last_name']
      w.author_institution = h['author_institution']

      w.date_uploaded = DateTime.parse( h['date_uploaded'] ) if h['date_uploaded']
      w.date_modified = DateTime.parse( h['date_modified'] ) if h['date_modified']
      w.date_created = DateTime.parse( h['date_created'] ) if h['date_created']
      w.visibility = h['visibility']
      w.visibility_during_embargo = h['visibility_during_embargo']
      w.embargo_state = h['embargo_state']
      w.embargo_period = h['embargo_period']
      w.description = h['description']
      w.work_type = h['work_type']
      w.draft = h['draft']

      w.publisher = h['publisher']
      w.department = h['department']
      w.degree = h['degree']
      w.notes = h['notes']
      w.admin_notes = h['admin_notes']
      w.language = h['language']

      w.contributor = h['contributor']

      w.rights = h['rights']
      w.license = h['license']

      w.identifier = h['identifier']
      w.permanent_url = h['permanent_url']
    end

    return work
  end

end   # namespace data

end   # namespace libra2

#
# end of file
#
