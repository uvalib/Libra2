#
# Some helper tasks to edit works
#

# pull in the helpers
require_dependency 'libra2/tasks/task_helpers'
include TaskHelpers

namespace :libra2 do

namespace :edit do

desc "Set title of work; must provide the work id and title"
task set_title_by_id: :environment do |t, args|

  work_id = ARGV[ 1 ]
  if work_id.nil?
    puts "ERROR: no work id specified, aborting"
    next
  end

  task work_id.to_sym do ; end

  title = ARGV[ 2 ]
  if title.nil?
    puts "ERROR: no title specified, aborting"
    next
  end

  task title.to_sym do ; end

  work = TaskHelpers.get_work_by_id( work_id )
  if work.nil?
    puts "ERROR: work #{work_id} does not exist, aborting"
    next
  end

  work.title = [ title ]
  work.save!
  puts "Work #{work_id} title updated to \"#{title}\""
end

desc "Set contributor of work; must provide the work id and contributor computing_id"
task set_contributor_by_id: :environment do |t, args|

  work_id = ARGV[ 1 ]
  if work_id.nil?
    puts "ERROR: no work id specified, aborting"
    next
  end

  task work_id.to_sym do ; end

  contributor_id = ARGV[ 2 ]
  if contributor_id.nil?
    puts "ERROR: no contributor specified, aborting"
    next
  end

  task contributor_id.to_sym do ; end

  work = TaskHelpers.get_work_by_id( work_id )
  if work.nil?
    puts "ERROR: work #{work_id} does not exist, aborting"
    next
  end

  contributor = TaskHelpers.contributor_fields( contributor_id )
  if contributor.nil? == false
     work.contributor = [ contributor ]
     work.save!
     puts "Work #{work_id} contributor updated to \"#{contributor_id}\""
  end

end

end   # namespace edit

end   # namespace libra2

#
# end of file
#
