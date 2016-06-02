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

    count = 0

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

    puts "#{count} items exported successfully"

  end

  end   # namespace data

end   # namespace libra2

#
# end of file
#
