#
# Some helper tasks to create and delete works
#

# pull in the helpers
require_dependency 'libra2/tasks/task_helpers'
include TaskHelpers

require_dependency 'libra2/lib/serviceclient/entity_id_client'

namespace :libra2 do

namespace :work do

default_user = "dpg3k@virginia.edu"
sample_pdf_file = "data/sample.pdf"

desc "List all works"
task list_all_works: :environment do |t, args|

   count = 0
   GenericWork.all.each do |generic_work|
     dump_work( generic_work )
     count += 1
   end

   puts "Listed #{count} work(s)"
end

desc "List all works (abbreviated)"
task list_all_works_abbrev: :environment do |t, args|

    abbrev_output(GenericWork.all)
end

desc "List all works (submitted)"
task list_all_works_submitted: :environment do |t, args|

    abbrev_output(GenericWork.where({draft: "false"}))
end

desc "List all works (draft)"
task list_all_works_draft: :environment do |t, args|

    abbrev_output(GenericWork.where({draft: "true"}))
end

desc "List all works (unmodified)"
task list_all_works_unmodified: :environment do |t, args|

    abbrev_output(GenericWork.where({draft: "true"}), true)
end

desc "List my works; optionally provide depositor email"
task list_my_works: :environment do |t, args|

  who = ARGV[ 1 ]
  who = default_user if who.nil?
  task who.to_sym do ; end

  count = 0
  GenericWork.all.each do |generic_work|
    if generic_work.is_mine?( who )
       dump_work( generic_work )
       count += 1
    end
  end

  puts "Listed #{count} work(s)"
end

desc "List work by id; must provide the work id"
task list_by_id: :environment do |t, args|

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

  dump_work( work )
end

desc "Delete all works"
task del_all_works: :environment do |t, args|

  count = 0
  GenericWork.all.each do |generic_work|
     count += 1
     print "."
     generic_work.destroy
  end
  puts "done" unless count == 0
  puts "Deleted #{count} work(s)"

end

desc "Delete my works; optionally provide depositor email"
task del_my_works: :environment do |t, args|

   who = ARGV[ 1 ]
   who = default_user if who.nil?
   task who.to_sym do ; end

   count = 0

   GenericWork.all.each do |generic_work|
     if generic_work.is_mine?( who )
        count += 1
        print "."
        generic_work.destroy
     end
   end

   puts "done" unless count == 0
   puts "Deleted #{count} work(s)"

end

desc "Delete work by id; must provide the work id"
task del_by_id: :environment do |t, args|

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

  work.destroy
  puts "Work deleted"
end

desc "Create new generic work; optionally provide depositor email"
task create_new_work: :environment do |t, args|

  who = ARGV[ 1 ]
  who = default_user if who.nil?
  task who.to_sym do ; end

  # lookup user and exit if error
  user = User.find_by_email( who )
  if user.nil?
    puts "ERROR: locating user #{who}, aborting"
    next
  end

  id = Time.now.to_i
  title = "Example generic work title (#{id})"
  description = "Example generic work description (#{id})"

  work = create_work( user, title, description )

  filename = TaskHelpers.get_random_image( )
  upload( user, work, filename )

  dump_work work

end

desc "Create new thesis; optionally provide depositor email"
task create_new_thesis: :environment do |t, args|

  who = ARGV[ 1 ]
  who = default_user if who.nil?
  task who.to_sym do ; end

  # lookup user and exit if error
  user = User.find_by_email( who )
  if user.nil?
    puts "ERROR: locating user #{who}, aborting"
    task who.to_sym do ; end
    next
  end

  id = Time.now.to_i
  title = "Example thesis title (#{id})"
  description = "Example thesis description (#{id})"

  work = create_thesis( user, title, description )

  #filename = copy_sourcefile( sample_pdf_file )
  #upload( user, work, filename )

  dump_work work

end

desc "Create new work for all registered users"
task works_for_all: :environment do |t, args|

  count = 0
  User.order( :email ).each do |user|

    id = Time.now.to_i
    title = "Example generic work title (#{id})"
    description = "Example generic work description (#{id})"

    work = create_work( user, title, description )

    filename = TaskHelpers.get_random_image( )
    upload( user, work, filename )

    count += 1
  end

  puts "Created #{count} works"

end

desc "Create new theses for all registered users"
task thesis_for_all: :environment do |t, args|

  count = 0
  User.order( :email ).each do |user|

    id = Time.now.to_i
    title = "Example thesis title (#{id})"
    description = "Example thesis description (#{id})"

    work = create_thesis( user, title, description )

    filename = TaskHelpers.get_random_image( )
    upload( user, work, filename )

    count += 1

  end

  puts "Created #{count} theses"

end

def abbrev_output(recs,unmodified_only = false)
    count = 0
    output = []
    recs.each do |generic_work|
        if !unmodified_only || !generic_work.date_modified.present?
        output.push({ id: generic_work.id, email: generic_work.author_email, identifier: generic_work.identifier,  title: generic_work.title.join(' '), created_at: generic_work.date_created, updated_at: generic_work.date_modified })
        count += 1
        end
    end
    output = output.sort { |a,b|
        a[:email] <=> b[:email]
    }
    output.each { |line|
        puts "#{line[:id]}\t#{line[:email]}\t#{line[:identifier]}\t#{line[:title]}\t#{line[:created_at]}\t#{line[:updated_at]}"
    }

    puts "Listed #{count} work(s)"
end

def create_work( user, title, description )
   return( create_generic_work( GenericWork::WORK_TYPE_GENERIC, user, title, description ) )
end

def create_thesis( user, title, description )
  return( create_generic_work( GenericWork::WORK_TYPE_THESIS, user, title, description ) )
end

def create_generic_work( work_type, user, title, description )

  # look up user details
  user_info = user_info_by_email( user.email )
  if user_info.nil?
    # fill in the defaults
    user_info = Helpers::UserInfo.create(
        "{'first_name': 'First name', 'last_name': 'Last name'}".to_json )
  end

  work = GenericWork.create!(title: [ title ] ) do |w|

    # generic work attributes
    w.apply_depositor_metadata(user)
    w.creator = user.email
    w.author_email = user.email
    w.author_first_name = user_info.first_name
    w.author_last_name = user_info.last_name
    w.author_institution = GenericWork::DEFAULT_INSTITUTION

    w.date_uploaded = CurationConcerns::TimeService.time_in_utc
    w.date_created = CurationConcerns::TimeService.time_in_utc.strftime( "%Y/%m/%d" )
    w.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    w.visibility_during_embargo = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    w.embargo_state = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    w.description = description
    w.work_type = work_type
    w.draft = work_type == GenericWork::WORK_TYPE_THESIS ? 'true' : 'false'

    w.publisher = GenericWork::DEFAULT_PUBLISHER
    w.department = 'Placeholder department'
    w.degree = 'Placeholder degree'
    w.notes = 'Placeholder notes'
    w.admin_notes << 'Placeholder admin notes'
    w.language = GenericWork::DEFAULT_LANGUAGE

    # assume I am the contributor
    w.contributor << TaskHelpers.contributor_fields( 'dpg3k' )

    w.rights << 'Determine your rights assignments here'
    w.license = GenericWork::DEFAULT_LICENSE

    print "getting DOI..."
    status, id = ServiceClient::EntityIdClient.instance.newid( w )
    if ServiceClient::EntityIdClient.instance.ok?( status )
       w.identifier = id
       w.permanent_url = w.doi_url( id )
       puts "done"
    else
       puts "error"
    end
  end

  return work
end

def upload( user, work, filename )

  print "uploading #{filename}... "

  fileset = ::FileSet.new
  file_actor = ::CurationConcerns::Actors::FileSetActor.new( fileset, user )
  file_actor.create_metadata( work )
  file_actor.create_content( File.open( filename ) )

  puts "done"

end

def dump_work( work )

  return if work.nil?
  j = JSON.parse( work.to_json )
  j.keys.sort.each do |k|
     val = j[ k ]
     if k.end_with?( "_id" ) == false && val.nil? == false
       next if val.respond_to?( :empty? ) && val.empty? == true
       puts " #{k} => #{val}"
     end
  end
  puts " visibility => #{work.visibility}"
  puts " embargo_end_date => #{work.embargo_end_date}"
  puts " registrar_computing_id => #{work.registrar_computing_id}"
  puts " sis_id => #{work.sis_id}"
  puts " sis_entry => #{work.sis_entry}"

  puts '*' * 40

end

def copy_sourcefile( source_file )

  dest_file = "#{File::SEPARATOR}tmp#{File::SEPARATOR}#{SecureRandom.hex( 5 )}#{File.extname( source_file )}"
  FileUtils.cp( source_file, dest_file )
  dest_file

end

end   # namespace work

end   # namespace libra2

#
# end of file
#
