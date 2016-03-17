#
# Some helper tasks to create and delete works
#

require "#{Rails.root}/lib/libra2/lib/serviceclient/entity_id_client"

namespace :libra2 do

default_user = "dpg3k@virginia.edu"
sample_file = "data/sample.pdf"
default_bulkfile = "data/bulk.data"

desc "List all works"
task list_all_works: :environment do |t, args|

   GenericWork.all.each do |generic_work|
      dump_work( generic_work )
   end
end

desc "List my works; optionally provide depositor name"
task list_my_works: :environment do |t, args|

  who = ARGV[ 1 ]
  who = default_user if who.nil?

  GenericWork.all.each do |generic_work|
    dump_work( generic_work ) if generic_work.depositor == who
  end

  task who.to_sym do ; end

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

desc "Delete my works; optionally provide depositor name"
task del_my_works: :environment do |t, args|

   who = ARGV[ 1 ]
   who = default_user if who.nil?
   count = 0

   GenericWork.all.each do |generic_work|
     if generic_work.depositor == who
        count += 1
        print "."
        generic_work.destroy
     end
   end

   puts "done" unless count == 0
   puts "Deleted #{count} work(s)"
   task who.to_sym do ; end

end

desc "Bulk create generic works; must specify filename containing details"
task bulk_create_work: :environment do |t, args|

  filename = ARGV[ 1 ]
  filename = default_bulkfile if filename.nil?

  title = ''
  description = ''
  who = ''
  
  count = 0
  number = 0

  File.open( filename ).each do |line|
    number += 1
    line = line.strip

    title = line if ( number % 3 ) == 1
    description = line if ( number % 3 ) == 2
    who = line if ( number % 3 ) == 0

    if number % 3 == 0
      puts "#{title}, #{description}, #{who}"

      user = User.find_by_email( who )
      work = create_generic_work( GenericWork::WORK_TYPE_GENERIC, user, title, description )
      def user.directory
        "#{File::SEPARATOR}tmp"
      end

      service = Sufia::IngestLocalFileService.new( user )
      filename = get_an_image( )
      upload_file( service, filename, work.id )

      count += 1
    end

  end

  puts "Created #{count} work(s)"
  task filename.to_sym do ; end

end

desc "Create new generic work; optionally provide depositor name"
task create_new_work: :environment do |t, args|

  who = ARGV[ 1 ]
  who = default_user if who.nil?

  user = User.find_by_email( who )
  id = Time.now.nsec
  title = "Example generic work title (#{id})"
  description = "Example generic work description (#{id})"

  work = create_generic_work( GenericWork::WORK_TYPE_GENERIC, user, title, description )

  def user.directory
    "#{File::SEPARATOR}tmp"
  end

  service = Sufia::IngestLocalFileService.new( user )
  2.times do
    filename = get_an_image( )
    upload_file( service, filename, work.id )
  end

  dump_work work
  task who.to_sym do ; end

end

desc "Create new thesis; optionally provide depositor name"
task create_new_thesis: :environment do |t, args|

  who = ARGV[ 1 ]
  who = default_user if who.nil?

  user = User.find_by_email( who )
  id = Time.now.nsec
  title = "Example thesis title (#{id})"
  description = "Example thesis description (#{id})"

  work = create_generic_work( GenericWork::WORK_TYPE_THESIS, user, title, description )

  def user.directory
    "#{File::SEPARATOR}tmp"
  end

  service = Sufia::IngestLocalFileService.new( user )
  filename = copy_sourcefile( sample_file )
  upload_file( service, filename, work.id )

  dump_work work
  task who.to_sym do ; end

end

def create_generic_work( work_type, user, title, description )

  id = SecureRandom.uuid
  upload_set = UploadSet.find_or_create( id )

  work = GenericWork.create!(title: [ title ], upload_set: upload_set) do |w|

    # generic work attributes
    w.apply_depositor_metadata(user)
    w.creator = user.email
    w.date_uploaded = CurationConcerns::TimeService.time_in_utc
    w.date_created = CurationConcerns::TimeService.time_in_utc.strftime( "%Y/%m/%d" )
    w.visibility = work_type == GenericWork::WORK_TYPE_THESIS ? Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE :
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    w.description = description
    w.work_type = work_type
    w.draft = work_type == GenericWork::WORK_TYPE_THESIS ? 'true' : 'false'

    w.publisher = GenericWork::DEFAULT_PUBLISHER
    w.department = 'Daves Special Department'
    w.degree = 'Super Master Ninja Person'
    w.notes = 'Created automatically by your friendly rake task'
    w.admin_notes << 'Created automatically by your friendly rake task'
    w.language = 'English'
    w.contributor << 'Dr. Ruth'

    print "getting DOI..."
    status, id = Libra2::EntityIdClient.instance.newid( w )
    w.identifier = id if Libra2::EntityIdClient.instance.ok?( status )
    puts "done" if Libra2::EntityIdClient.instance.ok?( status ) == true
    puts "error" if Libra2::EntityIdClient.instance.ok?( status ) == false

  end

  return work
end

def upload_file( uploader, filename, work_id )

  print "uploading #{filename}... "
  uploader.ingest_local_file( [ File.basename( filename ) ], work_id )
  puts "done"

end

def dump_work( work )

  j = JSON.parse( work.to_json )
  j.keys.sort.each do |k|
     val = j[ k ]
     if k.end_with?( "_id" ) == false && val.nil? == false && val.empty? == false
       puts " #{k} => #{val}"
     end
  end

  puts "*" * 30

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
