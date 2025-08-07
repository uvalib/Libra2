#
# Some helper tasks to show audit
#

namespace :libraetd do

namespace :metrics do

    desc "Show the work views, must provide the start and end dates (YYYY-MM-DD)"
    task show_views: :environment do |t, args|

      start_date = ARGV[ 1 ]
      if start_date.nil?
        puts "ERROR: no start date specified, aborting"
        next
      end
      task start_date.to_sym do ; end

      end_date = ARGV[ 2 ]
      if end_date.nil?
        puts "ERROR: no end date specified, aborting"
        next
      end
      task end_date.to_sym do ; end

      # validate the start date
      export_dt = convert_date( start_date )
      if export_dt.nil?
        puts "ERROR: start date must be in the form YYYY-MM-DD, aborting"
        next
      end

      # validate the end date
      export_dt = convert_date( end_date )
      if export_dt.nil?
        puts "ERROR: end date must be in the form YYYY-MM-DD, aborting"
        next
      end

      views = WorkViewStat.where( 'created_at >= ? AND created_at <= ?', start_date, end_date ).order( created_at: :asc )
      views.each do |v|
        puts v.to_json
      end
      puts "Displayed #{views.length} view record(s) (start: #{start_date}, end: #{end_date})"

    end

    desc "Export the work views, must provide the start and end dates (YYYY-MM-DD)"
    task export_views: :environment do |t, args|

      start_date = ARGV[ 1 ]
      if start_date.nil?
        puts "ERROR: no start date specified, aborting"
        next
      end
      task start_date.to_sym do ; end

      end_date = ARGV[ 2 ]
      if end_date.nil?
        puts "ERROR: no end date specified, aborting"
        next
      end
      task end_date.to_sym do ; end

      # validate the start date
      export_dt = convert_date( start_date )
      if export_dt.nil?
        puts "ERROR: start date must be in the form YYYY-MM-DD, aborting"
        next
      end

      # validate the end date
      export_dt = convert_date( end_date )
      if export_dt.nil?
        puts "ERROR: end date must be in the form YYYY-MM-DD, aborting"
        next
      end

      filename = "etd-work-views-export-#{Time.now.strftime("%m-%d-%Y-%H%M%S")}.json"
      views = WorkViewStat.where( 'created_at >= ? AND created_at <= ?', start_date, end_date ).order( created_at: :asc )
      File.open( filename, 'wt' ) do |f|
         views.each do |v|
           f.write( "#{v.to_json}\n" )
         end
         f.close
      end
      puts "Exported #{views.length} view record(s) to #{filename} (start: #{start_date}, end: #{end_date})"

    end

    desc "Show the file downloads, must provide the start and end dates (YYYY-MM-DD)"
    task show_downloads: :environment do |t, args|

      start_date = ARGV[ 1 ]
      if start_date.nil?
        puts "ERROR: no start date specified, aborting"
        next
      end
      task start_date.to_sym do ; end

      end_date = ARGV[ 2 ]
      if end_date.nil?
        puts "ERROR: no end date specified, aborting"
        next
      end
      task end_date.to_sym do ; end

      # validate the start date
      export_dt = convert_date( start_date )
      if export_dt.nil?
        puts "ERROR: start date must be in the form YYYY-MM-DD, aborting"
        next
      end

      # validate the end date
      export_dt = convert_date( end_date )
      if export_dt.nil?
        puts "ERROR: end date must be in the form YYYY-MM-DD, aborting"
        next
      end

      downloads = FileDownloadStat.where( 'created_at >= ? AND created_at <= ?', start_date, end_date ).order( created_at: :asc )
      downloads.each do |d|
        puts d.to_json
      end
      puts "Displayed #{downloads.length} download record(s) (start: #{start_date}, end: #{end_date})"

    end

    desc "Export the file downloads, must provide the start and end dates (YYYY-MM-DD)"
    task export_downloads: :environment do |t, args|

      start_date = ARGV[ 1 ]
      if start_date.nil?
        puts "ERROR: no start date specified, aborting"
        next
      end
      task start_date.to_sym do ; end

      end_date = ARGV[ 2 ]
      if end_date.nil?
        puts "ERROR: no end date specified, aborting"
        next
      end
      task end_date.to_sym do ; end

      # validate the start date
      export_dt = convert_date( start_date )
      if export_dt.nil?
        puts "ERROR: start date must be in the form YYYY-MM-DD, aborting"
        next
      end

      # validate the end date
      export_dt = convert_date( end_date )
      if export_dt.nil?
        puts "ERROR: end date must be in the form YYYY-MM-DD, aborting"
        next
      end

      filename = "etd-file-downloads-export-#{Time.now.strftime("%m-%d-%Y-%H%M%S")}.json"
      downloads = FileDownloadStat.where( 'created_at >= ? AND created_at <= ?', start_date, end_date ).order( created_at: :asc )
      File.open( filename, 'wt' ) do |f|
         downloads.each do |d|
           f.write( "#{d.to_json}\n" )
         end
         f.close
      end
      puts "Exported #{downloads.length} download record(s) to #{filename} (start: #{start_date}, end: #{end_date})"

    end

end   # namespace metrics

end   # namespace libraetd

#
# end of file
#
