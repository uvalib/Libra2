#
# Some helper tasks to create and delete users
#

require_dependency 'libra2/lib/serviceclient/user_info_client'
require_dependency 'libra2/lib/helpers/user_info'

namespace :libra2 do

  default_bulkfile = "data/user.data"
  default_password = "password"

desc "Delete all users"
task del_all_users: :environment do |t, args|

  count = 0
  User.all.each do |user|
     count += 1
     user.destroy
  end
  puts "Deleted #{count} user(s)"

end

desc "Delete specified user; provide email"
task del_user: :environment do |t, args|

  who = ARGV[ 1 ]

  user = User.find_by_email( who )
  if user
     user.destroy
     puts "Deleted #{who}"
  else
    puts "User #{who} does not exist"
  end

  task who.to_sym do ; end
end

desc "Create new user; provide name and email"
task create_user: :environment do |t, args|

  name = ARGV[ 1 ]
  email = ARGV[ 2 ]

  if name.nil? == false && email.nil? == false
     user = User.find_by_email( email )
     if user.nil?
       if create_user( name, email, default_password )
         puts "Created user: #{name} (#{email})"
       end
     else
       puts "Email #{email} already in use"
     end

     task name.to_sym do ; end
     task email.to_sym do ; end
  end

end

desc "Bulk create new users; optionally specify filename containing details (default is #{default_bulkfile})"
task bulk_create_user: :environment do |t, args|

  filename = ARGV[ 1 ]
  filename = default_bulkfile if filename.nil?

  name = ''
  email = ''

  count = 0
  ignored = 0
  number = 0

  File.open( filename ).each do |line|
    number += 1
    line = line.strip

    name = line if ( number % 2 ) == 1
    email = line if ( number % 2 ) == 0

    if number % 2 == 0
      user = User.find_by_email( email )
      if user.nil?
        if create_user( name, email, default_password )
           puts "Created user: #{name} (#{email})"
           count += 1
        end
      else
        puts "Email #{email} already in use"
        ignored += 1
      end
    end

  end

  puts "Created #{count} user(s), ignored #{ignored} user(s)"
  task filename.to_sym do ; end

end

desc "List all users"
task list_all_users: :environment do |t, args|

  User.all.each do |user|
    puts "#{user.display_name} (#{user.email})"
  end

end

desc "Sync all user data "
task sync_all_users: :environment do |t, args|

  User.all.each do |user|
    if sync_user( user ) == true
       puts "Updated user record for #{user.email}"
    end
  end

end

#
# create a new user record; attempt to lookup using the user info service
#
def create_user( name, email, password )

  # extract computing ID and look up...
  tokens = email.split( "@" )
  info = lookup_user( tokens[ 0 ] )

  display_name = info.nil? ? name : info.display_name
  title = info.nil? ? name : "#{info.description}, #{info.department}"
  user = User.new( email: email, password: password, password_confirmation: password, display_name: display_name, title: title )
  user.save!

  return true

end

#
# sync user data from the info service
#
def sync_user( user )

  # extract computing ID and look up...
  tokens = user.email.split( "@" )
  info = lookup_user( tokens[ 0 ] )
  updated = false

  if info.nil? == false

    if user.display_name != info.display_name
      user.display_name = info.display_name
      updated = true
    end

    if user.department != info.department
       user.department = info.department
       updated = true
    end

    if user.office != info.office
       user.office = info.office
       updated = true
    end

    if user.telephone != info.phone
       user.telephone = info.phone
       updated = true
    end

    if user.title != info.description
       user.title = info.description
       updated = true
    end

    if updated
       user.save!
    end
  end

  return updated
end

#
# lookup user information from the user info service
#
def lookup_user( id )

  info = nil
  status, resp = ServiceClient::UserInfoClient.instance.get_by_id( id )
  if ServiceClient::UserInfoClient.instance.ok?( status )
    info = Helpers::UserInfo.create( resp )
    puts "User #{id} lookup OK"
  else
    puts "User #{id} lookup failed (#{status})"
  end

  return( info )
end

end   # namespace

#
# end of file
#
