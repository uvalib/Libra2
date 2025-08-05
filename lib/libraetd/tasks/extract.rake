#
# Some helper tasks to create and delete works
#

# prefix for the export directories
EXPORT_DIR_PREFIX = "export"

namespace :libraetd do

namespace :export do

  desc "Export works by date; must provide the export directory and the creation start and end dates (YYYY-MM-DD)"
  task export_works: :environment do |t, args|

    export_dir = ARGV[ 1 ]
    if export_dir.nil?
      puts "ERROR: no export directory specified, aborting"
      next
    end
    task export_dir.to_sym do ; end

    # validate that the export directory is empty (so we dont overwrite anything important)
    if extract_dir_clean?(export_dir) == false
      puts "ERROR: export directory already contains items, aborting"
      next
    end

    start_export_date = ARGV[ 2 ]
    if start_export_date.nil?
      puts "ERROR: no start date specified, aborting"
      next
    end
    task start_export_date.to_sym do ; end

    end_export_date = ARGV[ 3 ]
    if end_export_date.nil?
      puts "ERROR: no end date specified, aborting"
      next
    end
    task end_export_date.to_sym do ; end

    # validate the start date
    export_dt = convert_date( start_export_date )
    if export_dt.nil?
      puts "ERROR: start date must be in the form YYYY-MM-DD, aborting"
      next
    end

    # validate the end date
    export_dt = convert_date( end_export_date )
    if export_dt.nil?
      puts "ERROR: end date must be in the form YYYY-MM-DD, aborting"
      next
    end

    # running totals
    count = 0
    errors = 0

    # our query constraint
    constraints = "has_model_ssim:GenericWork AND (system_create_dtsi:[#{start_export_date}T00:00:00Z TO #{end_export_date}T23:59:59Z])"

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

    puts "Exported #{count} work(s), #{errors} error(s) encountered (start: #{start_export_date}, end: #{end_export_date})"
  end

  desc "Count works by date; must provide the creation start and end dates (YYYY-MM-DD)"
  task count_works: :environment do |t, args|

    start_export_date = ARGV[ 1 ]
    if start_export_date.nil?
      puts "ERROR: no start date specified, aborting"
      next
    end
    task start_export_date.to_sym do ; end

    end_export_date = ARGV[ 2 ]
    if end_export_date.nil?
      puts "ERROR: no end date specified, aborting"
      next
    end
    task end_export_date.to_sym do ; end

    # validate the start date
    export_dt = convert_date( start_export_date )
    if export_dt.nil?
      puts "ERROR: start date must be in the form YYYY-MM-DD, aborting"
      next
    end

    # validate the end date
    export_dt = convert_date( end_export_date )
    if export_dt.nil?
      puts "ERROR: end date must be in the form YYYY-MM-DD, aborting"
      next
    end

    # running totals
    count = 0

    # our query constraint
    constraints = "has_model_ssim:GenericWork AND (system_create_dtsi:[#{start_export_date}T00:00:00Z TO #{end_export_date}T23:59:59Z])"

    # batched processing of generic works
    GenericWork.search_in_batches( constraints ) do |group|
      group.each do |gw_solr|
        count += 1
      end

    end

    puts "#{count} work(s) (start: #{start_export_date}, end: #{end_export_date})"
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
