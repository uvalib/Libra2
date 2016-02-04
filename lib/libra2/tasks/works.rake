#
#
#

namespace :libra2 do

  default_email = "dpg3k@virginia.edu"
  default_file = "data/dave_small.jpg"

desc "List all works"
task list_all: :environment do |t, args|

   GenericWork.all.each do |generic_work|
      dump_work( generic_work )
   end
end

desc "List my works; optionally provide depositor name"
task list_my: :environment do |t, args|

  who = ARGV[ 1 ]
  who = default_email if who.nil?

  GenericWork.all.each do |generic_work|
    dump_work( generic_work ) if generic_work.depositor == who
  end

  task who.to_sym do ; end

end

desc "Delete all works"
task del_all: :environment do |t, args|

  count = 0
  GenericWork.all.each do |generic_work|
     count += 1
     generic_work.destroy
  end
  puts "Deleted #{count} work(s)"

end

desc "Delete my works; optionally provide depositor name"
task del_my: :environment do |t, args|

   who = ARGV[ 1 ]
   who = default_email if who.nil?
   count = 0

   GenericWork.all.each do |generic_work|
     count += 1 if generic_work.depositor == who
     generic_work.destroy if generic_work.depositor == who
   end

   puts "Deleted #{count} work(s)"
   task who.to_sym do ; end

end

desc "Create new generic work; optionally provide depositor name"
task create: :environment do |t, args|

  who = ARGV[ 1 ]
  who = default_email if who.nil?

  time = Time.now
  upload_set = UploadSet.find_or_create( SecureRandom.uuid )
  user = User.find_by_email( who )
  title = "Generated title for #{who} at #{time}"
  description = "Description for #{who} at #{time}"

  work = GenericWork.create!(title: [ title ], upload_set: upload_set) do |w|

    # generic work attributes
    w.apply_depositor_metadata(user)
    w.creator << who
    w.date_uploaded = CurationConcerns::TimeService.time_in_utc
    w.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    w.description << description
    w.work_type = 'generic_work'
    w.draft = 'false'

  end

  # create an associated file
  filename = copy_sourcefile( default_file )
  def user.directory
    "#{File::SEPARATOR}tmp"
  end
  service = Sufia::IngestLocalFileService.new( user )
  service.ingest_local_file( [ File.basename( filename ) ], work.id )

  puts "Created new work (#{title})"
  task who.to_sym do ; end

end

desc "Create new thesis; libra2:create_thesis <jdoe@virginia.edu>"
task create_thesis: :environment do |t, args|

  who = ARGV[ 1 ]
  who = default_email if who.nil?

  time = Time.now
  upload_set = UploadSet.find_or_create( SecureRandom.uuid )
  user = User.find_by_email( who )
  title = "THESIS Generated title for #{who} at #{time}"
  description = "THESIS Description for #{who} at #{time}"

  work = GenericWork.create!(title: [ title ], upload_set: upload_set) do |w|

    # generic work attributes
    w.apply_depositor_metadata(user)
    w.creator << who
    w.date_uploaded = CurationConcerns::TimeService.time_in_utc
    w.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    w.description << description
    w.work_type = 'thesis'
    w.draft = 'true'

  end

  puts "Created new THESIS (#{title})"
  task who.to_sym do ; end

end

def dump_work( work )

  #puts "#{work.inspect}"
  puts "#{work.depositor}, #{work.title}"
  #if work.upload_set
  #  puts work.upload_set.inspect
  #end

end

def copy_sourcefile( source_file )

  dest_file = "#{File::SEPARATOR}tmp#{File::SEPARATOR}#{SecureRandom.hex( 5 )}#{File.extname( source_file )}"
  FileUtils.cp( source_file, dest_file )
  dest_file
end

end   # namespace

#
# end of file
#
