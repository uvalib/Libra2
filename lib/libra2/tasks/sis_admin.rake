#
# Some helper tasks to manage DOI submission
#

require_dependency 'libra2/lib/serviceclient/deposit_auth_client'

namespace :libra2 do

  namespace :sis do

  desc "Initiate the SIS import"
  task import: :environment do |t, args|

    # initiate the import
    status, count = ServiceClient::DepositAuthClient.instance.import
    if ServiceClient::DepositAuthClient.instance.ok?( status ) == false
      puts "ERROR: import request returns #{status}, aborting"
      next
    end

    puts "Import request successful; #{count} item(s) processed"

  end

  desc "Initiate the SIS export"
  task export: :environment do |t, args|

    # initiate the export
    status, count = ServiceClient::DepositAuthClient.instance.export
    if ServiceClient::DepositAuthClient.instance.ok?( status ) == false
      puts "ERROR: export request returns #{status}, aborting"
      next
    end

    puts "Export request successful; #{count} item(s) processed"

  end

  desc "Report SIS status; must provide a computingId (or part thereof)"
  task report_status: :environment do |t, args|

    cid = ARGV[ 1 ]
    if cid.nil?
      puts "ERROR: no computing Id, aborting"
      next
    end

    task cid.to_sym do ; end

    status, resp = ServiceClient::DepositAuthClient.instance.search_requests( cid )
    if ServiceClient::DepositAuthClient.instance.ok?( status )
      resp.each do |r|
        req = Helpers::DepositAuthorization.create( r )
        puts "Computing Id:   #{req.who}"
        puts "  from SIS:     #{req.created_at}"
        puts "  completed:    #{req.accepted_at.blank? ? 'incomplete' : req.accepted_at}"
        puts "  to SIS:       #{req.exported_at.blank? ? 'pending' : req.exported_at}"
      end
    else
      puts "No ETD deposit status located" if status == 404
      puts "ERROR: request returned #{status}" unless status == 404
    end
  end

  end   # namespace sis

end   # namespace libra2

#
# end of file
#
