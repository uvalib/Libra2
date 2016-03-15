#
# Some helper tasks to manage ETD creation
#

require "#{Rails.root}/lib/libra2/lib/serviceclient/deposit_reg_client"
require "#{Rails.root}/lib/libra2/lib/helpers/value_snapshot"
require "#{Rails.root}/lib/libra2/lib/helpers/deposit_request"

namespace :libra2 do

  default_last_id = "0"
  default_statefile = "#{Rails.root}/tmp/deposit-req.last"
  default_email_domain = "virginia.edu"

  desc "List new optional ETD deposit requests; optionally provide the last ETD deposit id"
  task list_optional_etd_deposits: :environment do |t, args|

    last_id = ARGV[ 1 ]
    last_id = default_last_id if last_id.nil?

    status, resp = Libra2::DepositRegClient.instance.list_requests( last_id )
    if Libra2::DepositRegClient.instance.ok?( status )
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

    s = Libra2::ValueSnapshot.new( statefile, default_last_id )
    last_id = s.val

    status, resp = Libra2::DepositRegClient.instance.list_requests( last_id )
    if Libra2::DepositRegClient.instance.ok?( status )
      resp.each do |r|
        if ingest_deposit_request( r, default_email_domain ) == true
           s.val = r[ 'id' ]
        else
          puts "ERROR ingesting request #{r[ 'id' ]}; stopping"
          break
        end

      end

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

  def ingest_deposit_request( req, domain )

    r = Libra2::DepositRequest.create( req )
    email = "#{r.who}@#{domain}"
    user = User.find_by_email( email )

    if user.nil? == false
       puts "ingesting ##{r.id}"
       return true
    end
    puts "Cannot locate user email #{email}"
    return false
  end

end   # namespace

#
# end of file
#
