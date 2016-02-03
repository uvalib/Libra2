#
# Rake tasks to create and delete theses within Libra.
#

namespace :libra2 do
  namespace :thesis do

  default_email = "greg@virginia.edu"

desc "List all theses"
task list_all: :environment do |t, args|

   Thesis.all.each do |thesis|
      dump( thesis )
   end
end

desc "List my theses; optionally provide depositor name"
task list_my: :environment do |t, args|

  who = ARGV[ 1 ]
  who = default_email if who.nil?

  Thesis.all.each do |thesis|
    dump( thesis ) if thesis.depositor == who
  end

  task who.to_sym do ; end

end

desc "Delete all theses"
task del_all: :environment do |t, args|

  count = 0
  Thesis.all.each do |thesis|
     count += 1
     thesis.destroy
  end
  puts "Deleted #{count} thesis(es)"

end

desc "Delete my theses; optionally provide depositor name"
task del_my: :environment do |t, args|

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

desc "Create new thesis; optionally provide depositor name"
task create: :environment do |t, args|

  who = ARGV[ 1 ]
  who = default_email if who.nil?

  time = Time.now
  upload_set = UploadSet.find_or_create( SecureRandom.uuid )
  user = User.find_by_email( who )
  title = "Generated thesis title for #{who} at #{time}"
  description = "Description #{who}'s thesis at #{time}"

  thesis = Thesis.create!(title: [ title ], upload_set: upload_set) do |t|

    # thesis attributes
    t.apply_depositor_metadata(user)
    t.creator << who
    t.date_uploaded = CurationConcerns::TimeService.time_in_utc
    t.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    t.description << description
    t.draft = true

  end

  puts "Created new thesis (#{title})"
  task who.to_sym do ; end

end

def dump( work )

  puts "#{work.depositor}, #{work.title}"

end

  end   # namespace
end   # namespace

#
# end of file
#
