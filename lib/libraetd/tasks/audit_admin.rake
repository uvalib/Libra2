#
# Some helper tasks to show audit
#

namespace :libraetd do

namespace :audit do

    desc "Show the audit history, must provide the audit start and end dates (YYYY-MM-DD)"
    task show: :environment do |t, args|

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

      audits = WorkAudit.where( 'created_at >= ? AND created_at <= ?', start_export_date, end_export_date ).order( created_at: :desc )
      audits.each do |a|
        puts a
      end
      puts "Displayed #{audits.length} audit record(s) (start: #{start_export_date}, end: #{end_export_date})"

    end

    desc "Export the audit history, must provide the audit start and end dates (YYYY-MM-DD)"
    task export: :environment do |t, args|

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

      filename = "etd-audit-export-#{Time.now.strftime("%m-%d-%Y-%H-%M-%S")}.tsv"
      audits = WorkAudit.where( 'created_at >= ? AND created_at <= ?', start_export_date, end_export_date ).order( created_at: :asc )
      File.open( filename, 'wt' ) do |f|
        audits.each do |a|
          f.write( "#{a.to_tsv}\n" )
        end
        f.close
      end
      puts "Exported #{audits.length} audit record(s) to #{filename} (start: #{start_export_date}, end: #{end_export_date})"

    end

end   # namespace audit

end   # namespace libraetd

#
# end of file
#
