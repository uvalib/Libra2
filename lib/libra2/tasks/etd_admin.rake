#
# Some helper tasks to manage ETD creation
#

require_dependency 'libra2/lib/serviceclient/deposit_reg_client'
require_dependency 'libra2/lib/helpers/value_snapshot'
require_dependency 'libra2/lib/helpers/deposit_request'
require_dependency 'libra2/lib/helpers/etd_helper'

namespace :libra2 do

  default_last_id = "0"
  default_statefile = "#{Rails.root}/tmp/deposit-req.last"

  desc "List new optional ETD deposit requests; optionally provide the last ETD deposit id"
  task list_optional_etd_deposits: :environment do |t, args|

    last_id = ARGV[ 1 ]
    last_id = default_last_id if last_id.nil?

    status, resp = ServiceClient::DepositRegClient.instance.list_requests( last_id )
    if ServiceClient::DepositRegClient.instance.ok?( status )
      resp.each do |r|
        dump_deposit_request r
      end

    else
      puts "No ETD deposit requests located" if status == 404
      puts "ERROR: request returned #{status}" unless status == 404
    end
    task last_id.to_sym do ; end

  end

  desc "List new SIS ETD deposit requests; optionally provide the last ETD deposit id"
  task list_sis_etd_deposits: :environment do |t, args|

    last_id = ARGV[ 1 ]
    last_id = default_last_id if last_id.nil?

    task last_id.to_sym do ; end

  end

  desc "Ingest new optional ETD deposit requests; optionally provide the statefile name"
  task ingest_optional_etd_deposits: :environment do |t, args|

    statefile = ARGV[ 1 ]
    statefile = default_statefile if statefile.nil?
    count = 0

    s = Helpers::ValueSnapshot.new( statefile, default_last_id )
    last_id = s.val

    status, resp = ServiceClient::DepositRegClient.instance.list_requests( last_id )
    if ServiceClient::DepositRegClient.instance.ok?( status )
      resp.each do |r|
        req = ServiceClient::DepositRequest.create( r )
        if Helpers::EtdHelper::new_etd_from_deposit_request( req ) == true
           count += 1
           #s.val = req.id
        else
          puts "ERROR ingesting request #{req.id} for #{req.who}; ignoring"
        end
        # temp
        s.val = req.id

      end

      puts "Done; #{count} ETD(s) created"
    else
      puts "No ETD deposit requests located" if status == 404
      puts "ERROR: request returned #{status}" unless status == 404
    end
    task last_id.to_sym do ; end

  end

  def dump_deposit_request( req )

    req.keys.each do |k|
      val = req[ k ]
      if val.nil? == false && val.empty? == false
        puts " #{k} => #{val}"
      end
    end

    puts "*" * 30
  end

end   # namespace

#
# end of file
#
