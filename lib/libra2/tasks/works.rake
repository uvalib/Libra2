# This rake script creates, deletes and dumps two kinds of work, a GenericWork
# and a Thesis.
#

namespace :libra2 do

  default_email = "greg@virginia.edu"
  default_file = "data/dave_small.jpg"

desc "List all works and theses"
task list_all: :environment do |t, args|

   GenericWork.all.each do |generic_work|
      dump_work( generic_work )
   end

   Thesis.all.each do |generic_work|
     dump_work( generic_work )
   end

end

desc "List all my works and theses; optionally provide depositor name"
task list_my: :environment do |t, args|

  who = ARGV[ 1 ]
  who = default_email if who.nil?

  GenericWork.all.each do |generic_work|
    dump_work( generic_work ) if generic_work.depositor == who
  end

  Thesis.all.each do |generic_work|
    dump_work( generic_work ) if generic_work.depositor == who
  end

  task who.to_sym do ; end

end

desc "Delete all generic works (non-thesis)"
task del_generic_works: :environment do |t, args|

  count = 0
  GenericWork.all.each do |generic_work|
     count += 1
     generic_work.destroy
  end
  puts "Deleted #{count} generic work(s)"

end

desc "Delete all theses (not generic works)"
task del_theses: :environment do |t, args|

  count = 0
  Thesis.all.each do |thesis|
    count += 1
    thesis.destroy
  end
  puts "Deleted #{count} thesis(es)"

end

desc "Delete my generic works (non-thesis); optionally provide depositor name"
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

desc "Delete my theses (not generic works); optionally provide depositor name"
task del_my_theses: :environment do |t, args|

  who = ARGV[ 1 ]
  who = default_email if who.nil?
  count = 0

  Thesis.all.each do |thesis|
    count += 1 if thesis.depositor == who
    thesis.destroy if thesis.depositor == who
  end

  puts "Deleted #{count} thesis(es)"
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

desc "Create new thesis; optionally provide depositor name"
task create_thesis: :environment do |t, args|

  who = ARGV[ 1 ]
  who = default_email if who.nil?

  time = Time.now
  upload_set = UploadSet.find_or_create( SecureRandom.uuid )
  user = User.find_by_email( who )
  title = "Generated title for thesis by #{who} at #{time}"
  description = "Description for thesis by #{who} at #{time}"

  work = Thesis.create!(title: [ title ], upload_set: upload_set) do |w|

    # generic work attributes
    w.apply_depositor_metadata(user)
    w.creator << who
    w.date_uploaded = CurationConcerns::TimeService.time_in_utc
    w.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    w.description << description

    # thesis attributes
    w.draft = true

  end

  # create an associated file
  #filename = copy_sourcefile( default_file )
  #def user.directory
  #  "#{File::SEPARATOR}tmp"
  #end
  #service = Sufia::IngestLocalFileService.new( user )
  #service.ingest_local_file( [ File.basename( filename ) ], work.id )

  puts "Created new thesis (#{title})"
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
