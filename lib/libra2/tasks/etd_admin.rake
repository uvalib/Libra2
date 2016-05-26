#
# Some helper tasks to manage ETD creation
#

require_dependency 'libra2/lib/serviceclient/deposit_reg_client'
require_dependency 'libra2/lib/serviceclient/deposit_auth_client'
require_dependency 'libra2/lib/helpers/value_snapshot'
require_dependency 'libra2/lib/helpers/deposit_request'
require_dependency 'libra2/lib/helpers/deposit_authorization'
require_dependency 'libra2/lib/helpers/etd_helper'

namespace :libra2 do

  default_last_id = "0"
  default_optional_statekey = "#{Rails.env.to_s}.deposit-opt.last"
  default_sis_statekey = "#{Rails.env.to_s}.deposit-sis.last"

  desc "List new optional ETD deposit requests; optionally provide the state key name"
  task list_optional_etd_deposits: :environment do |t, args|

    statekey = ARGV[ 1 ]
    statekey = default_optional_statekey if statekey.nil?

    s = Helpers::ValueSnapshot.new( statekey, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      next
    end

    puts "Listing new optional ETD deposits since id: #{last_id}"
    count = 0

    status, resp = ServiceClient::DepositRegClient.instance.list_requests( last_id )
    if ServiceClient::DepositRegClient.instance.ok?( status )
      resp.each do |r|
        dump_etd_request r
        count += 1
      end

      puts "#{count} optional ETD deposit(s) listed"
    else
      puts "No optional ETD deposit requests located" if status == 404
      puts "ERROR: request returned #{status}" unless status == 404
    end

    task statekey.to_sym do ; end

  end

  desc "List new SIS ETD deposit requests; optionally provide the state key name"
  task list_sis_etd_deposits: :environment do |t, args|

    statekey = ARGV[ 1 ]
    statekey = default_sis_statekey if statekey.nil?

    s = Helpers::ValueSnapshot.new( statekey, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      next
    end

    puts "Listing new SIS ETD deposits since id: #{last_id}"
    count = 0

    status, resp = ServiceClient::DepositAuthClient.instance.list_requests( last_id )
    if ServiceClient::DepositAuthClient.instance.ok?( status )
      resp.each do |r|
        dump_etd_request r
        count += 1
      end

      puts "#{count} SIS ETD deposit(s) listed"
    else
      puts "No SIS ETD deposit requests located" if status == 404
      puts "ERROR: request returned #{status}" unless status == 404
    end

    task statekey.to_sym do ; end

  end

  desc "Ingest new optional ETD deposit requests; optionally provide the state key name"
  task ingest_optional_etd_deposits: :environment do |t, args|

    statekey = ARGV[ 1 ]
    statekey = default_optional_statekey if statekey.nil?
    count = 0

    s = Helpers::ValueSnapshot.new( statekey, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      next
    end

    puts "Ingesting new optional ETD deposits since id: #{last_id}"

    status, resp = ServiceClient::DepositRegClient.instance.list_requests( last_id )
    if ServiceClient::DepositRegClient.instance.ok?( status )
      resp.each do |r|
        req = Helpers::DepositRequest.create( r )
        if Helpers::EtdHelper::new_etd_from_deposit_request( req ) == true
			     user = Helpers::EtdHelper::lookup_user( req.who )
           ThesisMailers.thesis_can_be_submitted( req.who, user.display_name ).deliver_now
           puts "Created placeholder (optional) ETD for #{req.who} (request #{req.id})"
           count += 1
        else
          puts "ERROR ingesting optional request #{req.id} for #{req.who}; ignoring"
        end

        # save the current ID so we do not process it again
        s.val = req.id

      end

      puts "Done; #{count} optional ETD(s) created"
    else
      puts "No optional ETD deposit requests located" if status == 404
      puts "ERROR: request returned #{status}" unless status == 404
    end

    task statekey.to_sym do ; end

  end

  desc "Ingest new SIS ETD deposit requests; optionally provide the state key name"
  task ingest_sis_etd_deposits: :environment do |t, args|

    statekey = ARGV[ 1 ]
    statekey = default_sis_statekey if statekey.nil?
    count = 0

    s = Helpers::ValueSnapshot.new( statekey, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      next
    end

    puts "Ingesting new SIS ETD deposits since id: #{last_id}"

    status, resp = ServiceClient::DepositAuthClient.instance.list_requests( last_id )
    if ServiceClient::DepositAuthClient.instance.ok?( status )
      resp.each do |r|
        req = Helpers::DepositAuthorization.create( r )
        if Helpers::EtdHelper::new_etd_from_sis_request( req ) == true
          puts "Created placeholder (SIS) ETD for #{req.who} (request #{req.id})"
          count += 1
        else
          puts "ERROR ingesting sis authorization #{req.id} for #{req.who}; ignoring"
        end

        # save the current ID so we do not process it again
        s.val = req.id

      end

      puts "Done; #{count} SIS ETD(s) created"
    else
      puts "No SIS ETD deposit requests located" if status == 404
      puts "ERROR: request returned #{status}" unless status == 404
    end

    task statekey.to_sym do ; end

  end

  desc "List optional deposit options"
  task list_deposit_options: :environment do |t, args|

    status, resp = ServiceClient::DepositRegClient.instance.list_deposit_options( )
    if ServiceClient::DepositRegClient.instance.ok?( status )

      resp['department'].each do |d|
         puts "Department: '#{d}'"
      end
      resp['degree'].each do |d|
         puts "Degree:     '#{d}'"
      end
    else
      puts "ERROR: options service returns #{status}"
    end

  end

  desc "List last SIS ETD id; optionally provide the state key name"
  task list_last_sis_id: :environment do |t, args|

    statekey = ARGV[ 1 ]
    statekey = default_sis_statekey if statekey.nil?

    s = Helpers::ValueSnapshot.new( statekey, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      next
    end

    puts "Last id: #{last_id}"
    task statekey.to_sym do ; end

  end

  desc "List last optional ETD id; optionally provide the state key name"
  task list_last_optional_id: :environment do |t, args|

    statekey = ARGV[ 1 ]
    statekey = default_optional_statekey if statekey.nil?

    s = Helpers::ValueSnapshot.new( statekey, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      next
    end

    puts "Last id: #{last_id}"
    task statekey.to_sym do ; end

  end

  desc "Reset last SIS ETD id; optionally provide the state key name"
  task reset_last_sis_id: :environment do |t, args|

    statekey = ARGV[ 1 ]
    statekey = default_sis_statekey if statekey.nil?

    s = Helpers::ValueSnapshot.new( statekey, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      next
    end

    s.val = 0

    puts "Reset (was #{last_id})"
    task statekey.to_sym do ; end

  end

  desc "Reset last optional ETD id; optionally provide the state key name"
  task reset_last_optional_id: :environment do |t, args|

    statekey = ARGV[ 1 ]
    statekey = default_optional_statekey if statekey.nil?

    s = Helpers::ValueSnapshot.new( statekey, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      next
    end

    s.val = 0

    puts "Reset (was #{last_id})"
    task statekey.to_sym do ; end

  end

  def dump_etd_request( req )

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
