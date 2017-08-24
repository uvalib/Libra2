#
# Some helper tasks to download files
#

# pull in the helpers
require_dependency 'libraetd/tasks/task_helpers'
include TaskHelpers

namespace :libraetd do

  namespace :download do

  desc "Download all files for the specified work; must provide the work id. Optionally provide target directory and scp username"
  task work_download: :environment do |t, args|

    work_id = ARGV[ 1 ]
    if work_id.nil?
      puts "ERROR: no work id specified, aborting"
      next
    end

    task work_id.to_sym do ; end

    target_dir = ARGV[ 2 ]
    if target_dir.nil?
      target_dir = '.'
    end

    task target_dir.to_sym do ; end

    username = ARGV[ 3 ]
    if username.nil?
      username = TaskHelpers::DEFAULT_USER
    end

    task username.to_sym do ; end

    work = TaskHelpers.get_work_by_id( work_id )
    if work.nil?
      puts "ERROR: work #{work_id} does not exist, aborting"
      next
    end

    if work.file_sets
      work.file_sets.each do |file_set|
        if TaskHelpers.copy_local_fileset( file_set, target_dir ) == false
           TaskHelpers.download_fileset( file_set, target_dir, username )
        end
      end
    end

  end

end   # namespace download

end   # namespace libraetd

#
# end of file
#
