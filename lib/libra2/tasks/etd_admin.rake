#
# Some helper tasks to manage ETD creation
#

# pull in the helpers
require_dependency 'libra2/tasks/task_helpers'
include TaskHelpers

require_dependency 'libra2/lib/serviceclient/deposit_reg_client'
require_dependency 'libra2/lib/serviceclient/deposit_auth_client'
require_dependency 'libra2/lib/helpers/value_snapshot'
require_dependency 'libra2/lib/helpers/deposit_request'
require_dependency 'libra2/lib/helpers/deposit_authorization'
require_dependency 'libra2/lib/helpers/etd_helper'

require 'socket'

namespace :libraetd do

  namespace :etd do

  # keys definitions for state
  default_last_id = "0"
  statekey_optional = "libra2:#{Rails.env.to_s}:deposit:optional:#{Socket.gethostname}"
  statekey_sis = "libra2:#{Rails.env.to_s}:deposit:sis:#{Socket.gethostname}"

  desc "List new optional ETD deposit requests"
  task list_new_optional_etd_deposits: :environment do |t, args|

    #puts "key: #{statekey_optional}"
    s = Helpers::ValueSnapshot.new( statekey_optional, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      next
    end

    show_optional_since( last_id )

  end

  desc "List all optional ETD deposit requests"
  task list_all_optional_etd_deposits: :environment do |t, args|
    show_optional_since( 0 )
  end

  desc "List new SIS ETD deposit requests"
  task list_new_sis_etd_deposits: :environment do |t, args|

    #puts "key: #{statekey_sis}"
    s = Helpers::ValueSnapshot.new( statekey_sis, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      next
    end

    show_sis_since( last_id )

  end

  desc "List all SIS ETD deposit requests"
  task list_all_sis_etd_deposits: :environment do |t, args|
    show_sis_since( 0 )
  end

  desc "Ingest new optional ETD deposit requests"
  task ingest_optional_etd_deposits: :environment do |t, args|

    count = 0

    #puts "key: #{statekey_optional}"
    s = Helpers::ValueSnapshot.new( statekey_optional, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      puts "Releasing permission token"
      t.release
      next
    end

    puts "Ingesting new optional ETD deposits since id: #{last_id}"

    status, resp = ServiceClient::DepositRegClient.instance.list_requests( last_id )
    if ServiceClient::DepositRegClient.instance.ok?( status )
      resp.each do |r|
        req = Helpers::DepositRequest.create( r )
        if Helpers::EtdHelper::new_etd_from_deposit_request( req ) == true
			     user = Helpers::EtdHelper::lookup_user( req.who )
           ThesisMailers.optional_thesis_can_be_submitted( user.email, user.display_name, MAIL_SENDER ).deliver_later
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

  end

  desc "Ingest new SIS ETD deposit requests"
  task ingest_sis_etd_deposits: :environment do |t, args|

    count = 0

    #puts "key: #{statekey_sis}"
    s = Helpers::ValueSnapshot.new( statekey_sis, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      puts "Releasing permission token"
      t.release
      next
    end

    puts "Ingesting new SIS ETD deposits since id: #{last_id}"

    status, resp = ServiceClient::DepositAuthClient.instance.list_requests( last_id )
    if ServiceClient::DepositAuthClient.instance.ok?( status )
      resp.each do |r|
        req = Helpers::DepositAuthorization.create( r )
        if Helpers::EtdHelper::new_etd_from_sis_request( req ) == true
          user = Helpers::EtdHelper::lookup_user( req.who )
          ThesisMailers.sis_thesis_can_be_submitted( user.email, user.display_name, MAIL_SENDER ).deliver_later
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

  end

  desc "Ingest specific SIS ETD deposit request; must supply the SIS deposit request id"
  task ingest_one_sis_etd_deposit: :environment do |t, args|

    id = ARGV[ 1 ]
    if id.nil?
      puts "ERROR: no SIS request id specified, aborting"
      next
    end
    task id.to_sym do ; end

    status, resp = ServiceClient::DepositAuthClient.instance.get_request( id )
    if ServiceClient::DepositAuthClient.instance.ok?( status )

      resp.each do |r|
        req = Helpers::DepositAuthorization.create( r )
        if Helpers::EtdHelper::new_etd_from_sis_request( req ) == true
          user = Helpers::EtdHelper::lookup_user( req.who )
          ThesisMailers.sis_thesis_can_be_submitted( user.email, user.display_name, MAIL_SENDER ).deliver_later
          puts "Created placeholder (SIS) ETD for #{req.who} (request #{req.id})"
        else
          puts "ERROR ingesting sis authorization #{req.id} for #{req.who}; ignoring"
        end
      end
    else
      puts "No SIS deposit request located" if status == 404
      puts "ERROR: request returned #{status}" unless status == 404
    end

  end

  desc "Ingest specific optional ETD deposit request; must supply the optional deposit request id"
  task ingest_one_optional_etd_deposit: :environment do |t, args|

    id = ARGV[ 1 ]
    if id.nil?
      puts "ERROR: no optional request id specified, aborting"
      next
    end
    task id.to_sym do ; end

    puts "NOT IMPLEMENTED YET"

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

  desc "List last SIS ETD id"
  task list_last_sis_id: :environment do |t, args|

    #puts "key: #{statekey_sis}"
    s = Helpers::ValueSnapshot.new( statekey_sis, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      next
    end

    puts "Last id: #{last_id}"

  end

  desc "List last optional ETD id"
  task list_last_optional_id: :environment do |t, args|

    #puts "key: #{statekey_optional}"
    s = Helpers::ValueSnapshot.new( statekey_optional, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      next
    end

    puts "Last id: #{last_id}"

  end

  desc "Reset last SIS ETD id; optionally provide the last id"
  task reset_last_sis_id: :environment do |t, args|

    id = ARGV[ 1 ]
    id = default_last_id if id.nil?
    task id.to_sym do ; end

    #puts "key: #{statekey_sis}"
    s = Helpers::ValueSnapshot.new( statekey_sis, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      next
    end

    s.val = id.to_i

    puts "Reset to #{id}, was #{last_id}"

  end

  desc "Reset last optional ETD id; optionally provide the last id"
  task reset_last_optional_id: :environment do |t, args|

    id = ARGV[ 1 ]
    id = default_last_id if id.nil?
    task id.to_sym do ; end

    #puts "key: #{statekey_optional}"
    s = Helpers::ValueSnapshot.new( statekey_optional, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      next
    end

    s.val = id.to_i

    puts "Reset to #{id}, was #{last_id}"

  end

  desc "Mark SIS EDT as submitted; must provide the work id"
  task mark_sis_etd_as_submitted: :environment do |t, args|

    work_id = ARGV[ 1 ]
    if work_id.nil?
      puts "ERROR: no ETD id specified, aborting"
      next
    end

    task work_id.to_sym do ; end

    work = TaskHelpers.get_work_by_id( work_id )
    if work.nil?
      puts "ERROR: ETD #{work_id} does not exist, aborting"
      next
    end

    if work.is_sis_thesis? == false
      puts "ERROR: ETD #{work_id} is not a SIS thesis, aborting"
      next
    end

    status = ServiceClient::DepositAuthClient.instance.request_fulfilled( work )
    if ServiceClient::DepositAuthClient.instance.ok?( status ) == false
      puts "ERROR: request returns #{status}, aborting"
      next
    end

    puts "Marked SIS ETD #{work_id} as submitted"

  end

  def show_sis_since( since_id )

    puts "Listing SIS ETD deposits since id: #{since_id}"
    count = 0

    status, resp = ServiceClient::DepositAuthClient.instance.list_requests( since_id )
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

  end

  def show_optional_since( since_id )

    puts "Listing optional ETD deposits since id: #{since_id}"
    count = 0

    status, resp = ServiceClient::DepositRegClient.instance.list_requests( since_id )
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

  end

  def dump_etd_request( req )

    req.keys.each do |k|
      show_field( k, req[ k ] )
    end

    puts "*" * 40
  end

  end   # namespace etd

end   # namespace libraetd

#
# end of file
#
