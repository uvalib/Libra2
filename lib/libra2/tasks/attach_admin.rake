#
# Some helper tasks to edit works
#

# pull in the helpers
require_dependency 'libra2/tasks/task_helpers'
include TaskHelpers

namespace :libra2 do

namespace :attach do

    desc "Add new attachment to existing work; must provide the work id and file to attach"
    task add: :environment do |t, args|

      work_id = ARGV[ 1 ]
      if work_id.nil?
        puts "ERROR: no work id specified, aborting"
        next
      end

      task work_id.to_sym do ; end

      file_name = ARGV[ 2 ]
      if file_name.nil?
        puts "ERROR: no file specified, aborting"
        next
      end

      task file_name.to_sym do ; end

      if File.file?( file_name ) == false
        puts "ERROR: file #{file_name} does not exist, aborting"
        next
      end

      work = TaskHelpers.get_work_by_id( work_id )
      if work.nil?
        puts "ERROR: work #{work_id} does not exist, aborting"
        next
      end

      user = User.find_by_email( TaskHelpers.default_user_email )
      if user.nil?
        puts "ERROR: default user #{TaskHelpers.default_user_email} is not available, aborting"
        next
      end

      TaskHelpers.upload_file( user, work, file_name, File.basename( file_name ) )
      puts "File #{file_name} attached to work id #{work_id}"

    end

    desc "Remove an attachment from an existing work; must provide the work id and the attachment number to remove"
    task remove: :environment do |t, args|

      work_id = ARGV[ 1 ]
      if work_id.nil?
        puts "ERROR: no work id specified, aborting"
        next
      end

      task work_id.to_sym do ; end

      file_number = ARGV[ 2 ]
      if file_number.nil?
        puts "ERROR: no file number specified, aborting"
        next
      end

      task file_number.to_sym do ; end

      work = TaskHelpers.get_work_by_id( work_id )
      if work.nil?
        puts "ERROR: work #{work_id} does not exist, aborting"
        next
      end

      fn = file_number.to_i
      if fn <= 0
        puts "ERROR: #{file_number} is not a valid file number, aborting"
        next
      end

      if work.file_sets.nil? || work.file_sets.length < fn
        puts "ERROR: work #{work_id} does not have a file number #{file_number}, aborting"
        next
      end

      user = User.find_by_email( TaskHelpers.default_user_email )
      if user.nil?
        puts "ERROR: default user #{TaskHelpers.default_user_email} is not available, aborting"
        next
      end

      TaskHelpers.delete_fileset( user, work.file_sets[ fn - 1 ] )

      puts "File number #{file_number} deleted from work id #{work_id}"
    end

    desc "Replace attachments for an existing work; must provide the work id and file to attach"
    task replace: :environment do |t, args|

      work_id = ARGV[ 1 ]
      if work_id.nil?
        puts "ERROR: no work id specified, aborting"
        next
      end

      task work_id.to_sym do ; end

      file_name = ARGV[ 2 ]
      if file_name.nil?
        puts "ERROR: no file specified, aborting"
        next
      end

      task file_name.to_sym do ; end

      if File.file?( file_name ) == false
        puts "ERROR: file #{file_name} does not exist, aborting"
        next
      end

      work = TaskHelpers.get_work_by_id( work_id )
      if work.nil?
        puts "ERROR: work #{work_id} does not exist, aborting"
        next
      end

      user = User.find_by_email( TaskHelpers.default_user_email )
      if user.nil?
        puts "ERROR: default user #{TaskHelpers.default_user_email} is not available, aborting"
        next
      end

      if work.file_sets.nil? == false
        work.file_sets.each do |fs|
           TaskHelpers.delete_fileset( user, fs )
        end
      end

      TaskHelpers.upload_file( user, work, file_name, File.basename( file_name ) )
      puts "File #{file_name} attached to work id #{work_id}"

    end

end   # namespace attach

end   # namespace libra2

#
# end of file
#
