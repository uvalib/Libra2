#
# Some helper tasks to list and search ORCID's
#

require_dependency 'libra2/lib/serviceclient/orcid_access_client'

namespace :libra2 do

  namespace :orcid do

  desc "Harvest ORCID's"
  task harvest_orcids: :environment do |t, args|

     count = 0
     User.order( :email ).each do |user|
       if user.orcid.blank? == false
         orcid = user.orcid.gsub( 'http://orcid.org/', '' )
         cid = User.cid_from_email( user.email )
         puts "Setting #{cid} ORCID to: #{orcid}"
         status = ServiceClient::OrcidAccessClient.instance.set_by_cid( cid, orcid )
         if ServiceClient::EntityIdClient.instance.ok?( status )
           count += 1
         else
           puts "ERROR: ORCID service returns #{status}, aborting"
           next
         end
       end
     end

     puts "#{count} ORCID(s) harvested"
  end

  desc "Search ORCID; provide a search pattern"
  task search_orcid: :environment do |t, args|

    search = ARGV[ 1 ]
    if search.nil?
      puts "ERROR: no search parameter specified, aborting"
      next
    end

    task search.to_sym do ; end

    count = 0
    status, r = ServiceClient::OrcidAccessClient.instance.search( search, "0", "100" )
    if ServiceClient::EntityIdClient.instance.ok?( status )
      r.each do |details|
        puts "#{details['last_name']}, #{details['first_name']} (#{details['display_name']}) -> #{details['id']}"
        count += 1
      end
      puts "#{count} ORCIDS(s) listed"

    else
      puts "ERROR: ORCID service returns #{status}, aborting"
    end

  end

  end   # namespace orcid

end   # namespace libra2

#
# end of file
#
