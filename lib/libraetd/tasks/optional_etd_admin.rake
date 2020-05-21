#
# Some helper tasks to manage optional ETD creation
#

# pull in the helpers
require_dependency 'libraetd/tasks/task_helpers'
include TaskHelpers

require_dependency 'libraetd/lib/serviceclient/deposit_reg_client'
require_dependency 'libraetd/lib/helpers/value_snapshot'
require_dependency 'libraetd/lib/helpers/deposit_request'
require_dependency 'libraetd/lib/helpers/etd_helper'

require 'socket'

namespace :libraetd do

  namespace :optionaletd do

  # keys definitions for state
  default_last_id = "0"
  statekey_optional = "libra-etd:deposit:optional:#{ENV['DOCKER_HOST']}"

  desc "List new optional ETD deposit requests"
  task list_new_optional_etd_deposits: :environment do |t, args|

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

  desc "Ingest new optional ETD deposit requests"
  task ingest_optional_etd_deposits: :environment do |t, args|

    s = Helpers::ValueSnapshot.new( statekey_optional, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      puts "INFO: releasing permission token"
      t.release
      next
    end

    puts "INFO: ingesting new optional ETD deposits since id: #{last_id}"

    successes = 0
    errors = 0

    status, resp = ServiceClient::DepositRegClient.instance.list_requests( last_id )
    if ServiceClient::DepositRegClient.instance.ok?( status )
      resp.each do |r|
        req = Helpers::DepositRequest.create( r )
        if Helpers::EtdHelper::process_inbound_optional_authorization(req ) == true
           puts "INFO: created placeholder (optional) ETD for #{req.who} (request #{req.id})"
           successes += 1
        else
          puts "ERROR ingesting optional request #{req.id} for #{req.who}; ignoring"
          errors += 1
        end

        # save the current ID so we do not process it again
        s.val = req.id

      end

      puts "INFO: done; #{successes} optional ETD(s) created, #{errors} error(s) encountered"
    else
      puts "INFO: no optional ETD deposit requests located" if status == 404
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

  desc "List last optional ETD id"
  task list_last_optional_id: :environment do |t, args|

    s = Helpers::ValueSnapshot.new( statekey_optional, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      next
    end

    puts "Last id: #{last_id}"

  end

  desc "Reset last optional ETD id; optionally provide the last id"
  task reset_last_optional_id: :environment do |t, args|

    id = ARGV[ 1 ]
    id = default_last_id if id.nil?
    task id.to_sym do ; end

    s = Helpers::ValueSnapshot.new( statekey_optional, default_last_id )
    last_id = s.val

    if last_id.nil? || last_id.blank?
      puts "ERROR: loading last processed id, aborting"
      next
    end

    s.val = id.to_i

    puts "Reset to #{id}, was #{last_id}"

  end

  def show_optional_since( since_id )

    puts "INFO: listing optional ETD deposits since id: #{since_id}"
    count = 0

    status, resp = ServiceClient::DepositRegClient.instance.list_requests( since_id )
    if ServiceClient::DepositRegClient.instance.ok?( status )
      resp.each do |r|
        dump_etd_request r
        count += 1
      end

      puts "INFO: #{count} optional ETD deposit(s) listed"
    else
      puts "INFO: no optional ETD deposit requests located" if status == 404
      puts "ERROR: request returned #{status}" unless status == 404
    end

  end

  def dump_etd_request( req )

    req.keys.each do |k|
      show_field( k, req[ k ] )
    end

    puts "*" * 40
  end

  end   # namespace optionaletd

end   # namespace libraetd

#
# end of file
#
