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
         if ServiceClient::OrcidAccessClient.instance.ok?( status )
           count += 1
         else
           puts "ERROR: ORCID service returns #{status}, aborting"
           next
         end
       end
     end

     puts "#{count} ORCID(s) harvested"
  end

  desc "Search ORCID; must provide a search pattern, optionally provide a start index and max count"
  task search_orcid: :environment do |t, args|

    search = ARGV[ 1 ]
    if search.nil?
      puts "ERROR: no search parameter specified, aborting"
      next
    end

    task search.to_sym do ; end

    start = ARGV[ 2 ]
    if start.nil?
      start = "0"
    end

    task start.to_sym do ; end

    max = ARGV[ 3 ]
    if max.nil?
      max = "100"
    end

    task max.to_sym do ; end

    count = 0
    status, r = ServiceClient::OrcidAccessClient.instance.search( search, start, max )
    if ServiceClient::OrcidAccessClient.instance.ok?( status )
      r.each do |details|
        puts "#{details['last_name']}, #{details['first_name']} (#{details['display_name']}) -> #{details['orcid']}"
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
