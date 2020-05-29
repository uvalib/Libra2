#
# Some helper tasks to manage ETD creation
#

# pull in the helpers
require_dependency 'libraetd/tasks/task_helpers'
include TaskHelpers

require_dependency 'libraetd/lib/serviceclient/deposit_auth_client'
require_dependency 'libraetd/lib/helpers/value_snapshot'
require_dependency 'libraetd/lib/helpers/deposit_authorization'
require_dependency 'libraetd/lib/helpers/etd_helper'

require 'socket'

namespace :libraetd do

  namespace :sisetd do

  # keys definitions for state
  default_last_id = "0"
  statekey_sis = "libra-etd-deposit-sis-#{ENV['DOCKER_HOST']}"

  #
  #
  desc "List new inbound SIS ETD deposit requests"
  task list_new_sis_etd_deposits: :environment do |t, args|

    s = Helpers::ValueSnapshot.new( statekey_sis, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      next
    end

    show_sis_since( last_id )

  end

  #
  #
  desc "List all inbound SIS ETD deposit requests"
  task list_all_sis_etd_deposits: :environment do |t, args|
    show_sis_since( 0 )
  end

  #
  #
  desc "Ingest new inbound SIS ETD deposit requests"
  task ingest_sis_etd_deposits: :environment do |t, args|

    s = Helpers::ValueSnapshot.new( statekey_sis, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      puts "INFO: releasing permission token"
      t.release
      next
    end

    puts "INFO: ingesting new inbound SIS ETD deposits since id: #{last_id}"

    successes = 0
    errors = 0

    status, resp = ServiceClient::DepositAuthClient.instance.get_all_inbound( last_id )
    if ServiceClient::DepositAuthClient.instance.ok?( status )
      resp.each do |r|
        req = Helpers::DepositAuthorization.create( r )
        if Helpers::EtdHelper::process_inbound_sis_authorization(req ) == true
          puts "INFO: created or updated (SIS) ETD for #{req.who} (inbound #{req.inbound_id})"
          successes += 1
        else
          puts "ERROR: processing inbound SIS authorization #{req.inbound_id} for #{req.who}; ignoring"
          errors += 1
        end

        # save the current inbound ID so we do not process it again
        s.val = req.inbound_id

      end

      puts "INFO: done; #{successes} inbound SIS ETD(s) created or updated, #{errors} error(s) encountered"
    else
      puts "INFO: no inbound SIS ETD deposit requests located" if status == 404
      puts "ERROR: request returned #{status}" unless status == 404
    end

  end

  #
  #
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
        if Helpers::EtdHelper::process_inbound_sis_authorization(req ) == true
          puts "INFO: created or updated (SIS) ETD for #{req.who} (request #{req.id})"
        else
          puts "ERROR: processing SIS authorization #{req.id} for #{req.who}; ignoring"
        end
      end
    else
      puts "INFO: no inbound SIS deposit requests located" if status == 404
      puts "ERROR: request returned #{status}" unless status == 404
    end

  end

  #
  #
  desc "List last inbound id"
  task list_last_inbound_id: :environment do |t, args|

    s = Helpers::ValueSnapshot.new( statekey_sis, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      next
    end

    puts "Last id: #{last_id}"

  end

  #
  #
  desc "Reset last inbound id; optionally provide the last id"
  task reset_last_inbound_id: :environment do |t, args|

    id = ARGV[ 1 ]
    id = default_last_id if id.nil?
    task id.to_sym do ; end

    s = Helpers::ValueSnapshot.new( statekey_sis, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      next
    end

    s.val = id.to_i

    puts "Reset to #{id}, was #{last_id}"

  end

  #
  #
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

    puts "INFO: marked SIS ETD #{work_id} as submitted"

  end

  private

  def show_sis_since( since_id )

    puts "INFO: listing SIS ETD deposits since id: #{since_id}"
    count = 0

    status, resp = ServiceClient::DepositAuthClient.instance.get_all_inbound( since_id )
    if ServiceClient::DepositAuthClient.instance.ok?( status )
      resp.each do |r|
        dump_etd_request r
        count += 1
      end

      puts "INFO: #{count} SIS ETD deposit(s) listed"
    else
      puts "INFO: no inbound SIS ETD deposit requests located" if status == 404
      puts "ERROR: request returned #{status}" unless status == 404
    end

  end

  def dump_etd_request( req )

    req.keys.each do |k|
      show_field( k, req[ k ] )
    end

    puts "*" * 40
  end

  end   # namespace sisetd

end   # namespace libraetd

#
# end of file
#
