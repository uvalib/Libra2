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

      audits = WorkAudit.all.order( created_at: :asc )
      audits.each do |a|
        puts a.to_psv
      end
      puts "Exported #{audits.length} audit record(s)"

    end

end   # namespace audit

end   # namespace libraetd

#
# end of file
#
