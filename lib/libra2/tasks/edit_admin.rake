#
# Some helper tasks to edit works
#

# pull in the helpers
require_dependency 'libra2/tasks/task_helpers'
include TaskHelpers

namespace :libra2 do

namespace :edit do
  desc "Delete a work; must provide the work id and that work must be untouched by the user."
  task delete_work_by_id: :environment do |t, args|

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
    if work.draft != "true"
      puts "ERROR: work #{work_id} must not have been submitted, aborting"
      next
    end
    if work.date_modified.present?
      puts "ERROR: work #{work_id} must not have been modified by the user, aborting"
      next
    end

    work.destroy!
    puts "Work #{work_id} deleted."
  end

  desc "Delete my optional, untouched works."
  task delete_my_optional_untouched_works: :environment do |t, args|

	  works = GenericWork.where({ author_email: "per4k@virginia.edu" })
	  works.each { |work|
     if work.draft != "true"
      puts "Skipping work #{work.id} [already submitted]"
    end
    if work.date_modified.present?
      puts "Skipping work #{work.id} [already modified]"
    end

    work.destroy!
    puts "Work #{work.id} deleted. #{work.author_email} #{work.title}"
	  }
  end

  desc "Backfill all the sis data for existing docs"
  task backfill_sis_data: :environment do |t, args|

    sis_file_path = ARGV[ 1 ]
    if sis_file_path.nil?
      puts "ERROR: no sis file specified, aborting"
      next
    end

    task sis_file_path.to_sym do ; end

    f = File.open(sis_file_path, "r")
    f.each_line do |line|
      line = line.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '[BAD CHAR]')
      arr = line.split("|")
      work = GenericWork.where({ author_email: "#{arr[1]}@virginia.edu" })
      if work.length == 0
        # the work has never been imported before
		  puts "skipping #{arr[1]}: not imported yet"
      else
        # The work was imported, add the sis parameters
		  puts "editing #{arr[1]}"
		  work.sis_id = arr[0]
		  work.sis_entry = line
		  work.save!
      end
    end

  end

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

desc "Add to contributor of work; must provide the work id and contributor computing_id"
task add_contributor_by_id: :environment do |t, args|

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
    c = Array.new( work.contributor )
    c << contributor
    work.contributor = c
    work.save!
    puts "Work #{work_id} contributor added \"#{contributor_id}\""
  end

end

desc "Add new file to existing work; must provide the work id and file name to add"
task add_file_to_work: :environment do |t, args|

  work_id = ARGV[ 1 ]
  if work_id.nil?
    puts "ERROR: no work id specified, aborting"
    next
  end

  task work_id.to_sym do ; end

  file_name = ARGV[ 2 ]
  if file_name.nil?
    puts "ERROR: no filename specified, aborting"
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

  user = User.find_by_email( TaskHelpers.default_user )
  if user.nil?
    puts "ERROR: default user #{TaskHelpers.default_user} is not available, aborting"
    next
  end

  TaskHelpers.upload_file( user, work, file_name )
  puts "File #{file_name} added to work id #{work_id}"

end

desc "Delete a file from an existing work; must provide the work id and file number to delete"
task del_file_from_work: :environment do |t, args|

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

  user = User.find_by_email( TaskHelpers.default_user )
  if user.nil?
    puts "ERROR: default user #{TaskHelpers.default_user} is not available, aborting"
    next
  end

  TaskHelpers.delete_fileset( user, work.file_sets[ fn - 1 ] )

  puts "File number #{file_number} deleted from work id #{work_id}"
end

desc "Set embargo of work; must provide the work id and embargo type and embargo period"
task set_embargo_by_id: :environment do |t, args|

  work_id = ARGV[ 1 ]
  if work_id.nil?
    puts "ERROR: no work id specified, aborting"
    next
  end

  task work_id.to_sym do ; end

  embargo_type = ARGV[ 2 ]
  if embargo_type.nil?
    puts "ERROR: no embargo type specified, aborting"
    next
  end

  task embargo_type.to_sym do ; end

  embargo_period = ARGV[ 3 ]
  if embargo_period.nil?
    puts "ERROR: no embargo period specified, aborting"
    next
  end

  task embargo_period.to_sym do ; end

  case embargo_type
    when 'engineering'
      embargo_type = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    when 'non'
      embargo_type = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
    else
      puts "ERROR: must specify \"engineering\" or \"non\" for embargo type"
      next
  end

  case embargo_period
    when GenericWork::EMBARGO_VALUE_6_MONTH,
         GenericWork::EMBARGO_VALUE_1_YEAR,
         GenericWork::EMBARGO_VALUE_2_YEAR,
         GenericWork::EMBARGO_VALUE_5_YEAR
    else
      puts "ERROR: must specify \"#{GenericWork::EMBARGO_VALUE_6_MONTH}\", \"#{GenericWork::EMBARGO_VALUE_1_YEAR}\", \"#{GenericWork::EMBARGO_VALUE_2_YEAR}\" or \"#{GenericWork::EMBARGO_VALUE_5_YEAR}\" for embargo period, aborting"
      next
  end

  work = TaskHelpers.get_work_by_id( work_id )
  if work.nil?
    puts "ERROR: work #{work_id} does not exist, aborting"
    next
  end

  if work.is_draft?
    puts "ERROR: work #{work_id} has not been submitted, aborting"
    next
  end

  work.embargo_state = embargo_type
  work.embargo_period = embargo_period

  end_date = work.resolve_embargo_date()
  work.embargo_end_date = DateTime.new(end_date.year, end_date.month, end_date.day)
  work.save!

  puts "Work #{work_id} embargo period updated to #{GenericWork.friendly_embargo_period embargo_period}"
end

  desc "Apply publication_date to all published works."
  task apply_publication_date: :environment do |t, args|

    count = 0
    works = GenericWork.where({ draft: 'false' })
    works.each { |work|

      if work.date_published.nil? == false
        puts "Skipping work #{work.id} (already has a publication date of #{work.date_published})"
        next
      end

      # if we have a modification date use it, otherwise use the create date
      if work.modified_date.nil? == false
        pub_date = work.modified_date.strftime( "%Y/%m/%d" )
        puts "Using modified_date as publication date for #{work.id} (#{pub_date})"
        work.date_published = pub_date
      else
        puts "Using create_date as publication date for #{work.id} (#{work.date_created})"
        work.date_published = work.date_created
      end

      work.save!
      count += 1
    }
    puts "#{count} works updated"
  end

end   # namespace edit

end   # namespace libra2

#
# end of file
#
