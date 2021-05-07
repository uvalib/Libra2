#
# Some helper tasks to create and delete works
#

# prefix for the export directories
EXPORT_DIR_PREFIX = "export"

namespace :libraetd do

namespace :export do

  desc "Export works by date; must provide the export directory and the publication date (YYYY-MM-DD)"
  task export_works: :environment do |t, args|

    export_dir = ARGV[ 1 ]
    if export_dir.nil?
      puts "ERROR: no export directory specified, aborting"
      next
    end
    task export_dir.to_sym do ; end

    export_date = ARGV[ 2 ]
    if export_date.nil?
      puts "ERROR: no export date specified, aborting"
      next
    end
    task export_date.to_sym do ; end

    # validate that the export directory is empty (so we dont overwrite anything important)
    if extract_dir_clean?(export_dir) == false
      puts "ERROR: extract directory already contains items, aborting"
      next
    end

    # validate the supplied date
    export_dt = convert_date( export_date )
    if export_dt.nil?
      puts "ERROR: extract date must be in the form YYYY-MM-DD, aborting"
      next
    end

    # running totals
    count = 0
    errors = 0

    # our query constraint
    constraints = "(date_published_ssim:[#{export_date} TO *])"

    # batched processing of generic works
    GenericWork.search_in_batches( constraints ) do |group|
      group.each do |gw_solr|
        begin
          count += 1
          gw = GenericWork.find( gw_solr['id'] )
          extract_generic_work( export_dir, count, gw )
        rescue => e
          puts e
          errors += 1
        end
      end

    end

    puts "Exported #{count} work(s), #{errors} error(s) encountered"
  end

  desc "Count works by date; must provide the publication date (YYYY-MM-DD)"
  task count_works: :environment do |t, args|

    export_date = ARGV[ 1 ]
    if export_date.nil?
      puts "ERROR: no export date specified, aborting"
      next
    end
    task export_date.to_sym do ; end

    # validate the supplied date
    export_dt = convert_date( export_date )
    if export_dt.nil?
      puts "ERROR: extract date must be in the form YYYY-MM-DD, aborting"
      next
    end

    # running totals
    count = 0

    # our query constraint
    constraints = "(date_published_ssim:[#{export_date} TO *])"

    # batched processing of generic works
    GenericWork.search_in_batches( constraints ) do |group|
      group.each do |gw_solr|
        count += 1
      end

    end

    puts "#{count} work(s) will be exported"
  end

  #
  # helpers
  #

  def extract_generic_work( export_dir, number, work )

    puts "==> extracting work #{number} (id: #{work.id})"

    dir = File.join( export_dir, "#{EXPORT_DIR_PREFIX}-#{work.id}" )
    FileUtils::mkdir_p( dir )

    work_json = work.to_json
    f = File.join( dir, "work.json" )
    File.open( f, 'w') do |file|
      file.write( work_json )
    end

    #ac = work.access_control
    #f = File.join( dir, "acl.json" )
    #File.open( f, 'w') do |file|
    #  file.write( ac.to_json )
    #end

    em = work.embargo
    f = File.join( dir, "embargo.json" )
    File.open( f, 'w') do |file|
      file.write( em.to_json )
    end

    if work.file_sets
      fileset_number = 0
      work.file_sets.each do |file_set|
        fileset_number += 1
        puts "  ==> dumping fileset #{fileset_number} (id: #{file_set.id})"
        fs_json= file_set.to_json
        f = File.join( dir, "fileset-#{fileset_number}.json" )
        File.open( f, 'w') do |file|
          file.write( fs_json )
        end

        download_file(dir, file_set)
      end
    end
  end

  #
  # download the file
  #
  def download_file(export_dir, file_set)

    ori_file = file_set.original_file
    if ori_file.nil? == false
      puts "  ==> downloading file #{file_set.title[ 0 ]}"
      f = File.join( export_dir, file_set.title[ 0 ] )
      File.open( f, 'wb') do |file|
        ori_file.stream.each do |in_buff|
          file.write in_buff
        end
      end
    end
  end

  #
  # check to ensure if the extract directory is empty
  #
  def extract_dir_clean?(dirname )
    items = get_extract_list(dirname )
    return items.empty?
  end

  #
  # get the list of SOLR extract items from the work directory
  #
  def get_extract_list(dirname )
    el = TaskHelpers.get_directory_list( dirname, /^#{EXPORT_DIR_PREFIX}/ )

    # sort by directory order
    return el.sort { |x, y| TaskHelpers.directory_sort_order( x, y ) }
  end

  #
  # converts a supplied date in the form YYYY-MM-DD to a DateTime object suitable for comparisons
  #
  def convert_date( date )

    date_format = '%Y-%m-%d'
    begin
      return DateTime.strptime( date, date_format )
    rescue => e
      return nil
    end
  end

end   # namespace export

end   # namespace libraetd

#
# end of file
#
