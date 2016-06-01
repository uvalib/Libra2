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

  end   # namespace sis

end   # namespace libra2

#
# end of file
#
