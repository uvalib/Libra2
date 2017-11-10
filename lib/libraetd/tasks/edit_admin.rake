#
# Some helper tasks to edit works
#

# pull in the helpers
require_dependency 'libraetd/tasks/task_helpers'
include TaskHelpers

namespace :libraetd do

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

  contributor = TaskHelpers.contributor_fields_from_cid( 0, contributor_id )
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

  new_ix = work.contributor.blank? ? 0 : work.contributor.length
  contributor = TaskHelpers.contributor_fields_from_cid( new_ix, contributor_id )
  if contributor.nil? == false
    work.contributor << contributor
    work.save!
    puts "Work #{work_id} contributor added \"#{contributor_id}\""
  end

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

  end_date = GenericWork.calculate_embargo_release_date( embargo_period )
  work.embargo_end_date = DateTime.new(end_date.year, end_date.month, end_date.day)
  work.save!

  puts "Work #{work_id} embargo period updated to #{GenericWork.displayable_embargo_period( embargo_period )}"
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
      pub_date = work.modified_date.strftime( "%Y-%m-%d" )
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

desc "Add to admin notes of work; must provide the work id and the admin note"
task admin_note_by_id: :environment do |t, args|

  work_id = ARGV[ 1 ]
  if work_id.blank?
    puts "ERROR: no work id specified, aborting"
    next
  end

  task work_id.to_sym do ; end

  admin_note = ARGV[ 2 ]
  if admin_note.blank?
    puts "ERROR: no admin note specified, aborting"
    next
  end

  task admin_note.to_sym do ; end

  work = TaskHelpers.get_work_by_id( work_id )
  if work.nil?
    puts "ERROR: work #{work_id} does not exist, aborting"
    next
  end

  admin_note = "#{DateTime.now} | #{admin_note}"

  work.admin_notes = [] if work.admin_notes.nil?
  work.admin_notes = work.admin_notes + [ admin_note ]
  work.save!
  puts "Work #{work_id} admin note added \"#{admin_note}\""

end

end   # namespace edit

end   # namespace libraetd

#
# end of file
#
