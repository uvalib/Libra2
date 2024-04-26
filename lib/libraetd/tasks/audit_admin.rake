#
# Some helper tasks to show audit
#

namespace :libraetd do

namespace :audit do

    desc "Show the full audit history"
    task all: :environment do |t, args|

      audits = WorkAudit.all.order( created_at: :desc )
      audits.each do |a|
        puts a
      end
      puts "Displayed #{audits.length} audit record(s)"

    end

    desc "Export the full audit history"
    task export: :environment do |t, args|

      filename = "etd-audit-export-#{Time.now.strftime("%m-%d-%Y-%H-%M-%S")}.tsv"
      audits = WorkAudit.all.order( created_at: :asc )
      File.open( filename, 'wt' ) do |f|
        audits.each do |a|
          f.write( "#{a.to_tsv}\n" )
        end
        f.close
      end
      puts "Exported #{audits.length} audit record(s) to #{filename}"

    end

end   # namespace audit

end   # namespace libraetd

#
# end of file
#
