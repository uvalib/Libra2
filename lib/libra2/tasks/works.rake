#
#
#

namespace :libra2 do

  default_email = "dpg3k@virginia.edu"

desc "List all works"
task all_works: :environment do |t, args|

   GenericWork.all.each do |generic_work|
      dump_work( generic_work )
   end
end

desc "List my works; provide depositor name"
task my_works: :environment do |t, args|

  who = ARGV[ 1 ]
  who = default_email if who.nil?

  GenericWork.all.each do |generic_work|
    dump_work( generic_work ) if generic_work.depositor == who
  end

  task who.to_sym do ; end

end

desc "Create new generic work"
task new_work: :environment do |t, args|

  time = Time.now
  upload_set = UploadSet.find_or_create( SecureRandom.uuid )
  user = User.find_by_email( default_email )
  title = "Generated title for #{default_email} at #{time}"
  description = "Description for #{default_email} at #{time}"

  GenericWork.create!(title: [ title ], upload_set: upload_set) do |w|
    w.apply_depositor_metadata(user)
    w.creator << default_email
    w.date_uploaded = CurationConcerns::TimeService.time_in_utc
    w.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    w.description << description
  end

end

def dump_work( work )

  #puts "#{work.inspect}"
  puts "#{work.depositor}, #{work.title}"
  #if work.upload_set
  #  puts work.upload_set.inspect
  #end

end

end   # namespace

#
# end of file
#