#
# Some helper tasks to manage ETD creation
#

require "#{Rails.root}/lib/libra2/lib/serviceclient/deposit_reg_client"

namespace :libra2 do

  desc "List new optional ETD deposit requests; optionally provide the last ETD deposit id"
  task list_optional_etd_deposits: :environment do |t, args|

    last_id = ARGV[ 1 ]
    last_id = "0" if last_id.nil?

    status, resp = Libra2::DepositRegClient.instance.list_requests( last_id )
    if Libra2::DepositRegClient.instance.ok?( status )
      resp.each do |r|
        dump_deposit_request r
      end

    else
      puts "ERROR: request returned #{status}"
    end
    task last_id.to_sym do ; end

  end

  desc "List new SIS ETD deposit requests; optionally provide the last ETD deposit id"
  task list_sis_etd_deposits: :environment do |t, args|

    last_id = ARGV[ 1 ]
    last_id = "0" if last_id.nil?

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
