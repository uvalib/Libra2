#
#
#

namespace :libra2 do

  default_email = "dpg3k@virginia.edu"
  sample_file = "data/sample.pdf"

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

  id = SecureRandom.uuid
  upload_set = UploadSet.find_or_create( id )
  user = User.find_by_email( who )
  title = "Example generic work title (#{id})"
  description = "Example generic work description (#{id})"

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

  def user.directory
    "#{File::SEPARATOR}tmp"
  end

  service = Sufia::IngestLocalFileService.new( user )
  2.times do
    filename = get_an_image( )
    print "uploading image... "
    service.ingest_local_file( [ File.basename( filename ) ], work.id )
    puts "done"
  end

  puts "Created new work (#{title})"
  task who.to_sym do ; end

end

desc "Create new thesis; libra2:create_thesis <jdoe@virginia.edu>"
task create_thesis: :environment do |t, args|

  who = ARGV[ 1 ]
  who = default_email if who.nil?

  id = SecureRandom.uuid
  upload_set = UploadSet.find_or_create( id )
  user = User.find_by_email( who )
  title = "Example thesis title (#{id})"
  description = "Example thesis description (#{id})"

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

  def user.directory
    "#{File::SEPARATOR}tmp"
  end

  service = Sufia::IngestLocalFileService.new( user )
  filename = copy_sourcefile( sample_file )
  print "uploading pdf... "
  service.ingest_local_file( [ File.basename( filename ) ], work.id )
  puts "done"

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

# download a random cat image to be used for the item
def get_an_image( )

  print "getting image... "

  dest_file = "#{File::SEPARATOR}tmp#{File::SEPARATOR}#{SecureRandom.hex( 5 )}.jpg"
  Net::HTTP.start( "lorempixel.com" ) do |http|
    resp = http.get("/640/480/cats/")
    open( dest_file, "wb" ) do |file|
      file.write( resp.body )
    end
  end
  puts "done"
  dest_file

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
