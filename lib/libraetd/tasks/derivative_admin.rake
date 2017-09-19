#
# Some helper tasks to manage asset derivatives
#

# pull in the helpers
require_dependency 'libraetd/tasks/task_helpers'
include TaskHelpers

namespace :libraetd do

namespace :derivative do

desc "Recreate derivatives for all works"
task recreate_all_works: :environment do |t, args|

  count = 0
  GenericWork.search_in_batches( {} ) do |group|
    TaskHelpers.batched_process_solr_works( group, &method( :recreate_derivatives_work_callback ) )
    count += group.size
  end

  puts "Recreated derivatives for #{count} work(s)"
end

desc "Recreate derivatives for specified work; must provide the work id"
task recreate_by_id: :environment do |t, args|

  work_id = ARGV[ 1 ]
  if work_id.nil?
    puts "ERROR: no work id specified, aborting"
    next
  end

  task work_id.to_sym do ; end

  work = TaskHelpers.get_work_by_id( work_id )
  if work.nil?
    puts "ERROR: work #{work_id} does not exist, aborting"
    next
  end

  recreate_derivatives_work_callback(work )
  puts "Recreated derivatives for work id #{work.id}"
end

#
# helpers
#

def recreate_derivatives_work_callback( work )
  puts "Recreating derivatives for work #{work.id}"
  work.file_sets.each do |fs|
    puts " processing file set #{fs.id}"
    asset_path = fs.original_file.uri.to_s
    asset_path = asset_path[ asset_path.index( fs.id.to_s )..-1 ]
    CreateDerivativesJob.perform_later( fs, asset_path )
  end
end

end   # namespace derivative

end   # namespace libraetd

#
# end of file
#
