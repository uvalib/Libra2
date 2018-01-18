#
# Some helper tasks to list and search ORCID's
#

require_dependency 'libraetd/lib/serviceclient/orcid_access_client'
require_dependency 'libraetd/app/helpers/orcid_helper'
include OrcidHelper

namespace :libraetd do

  namespace :orcid do

  desc "List known ORCID's from the ORCID service"
  task list_remote_orcids: :environment do |t, args|

    count = 0
    status, r = ServiceClient::OrcidAccessClient.instance.get_attribs_all( )
    if ServiceClient::OrcidAccessClient.instance.ok?( status )
      r.sort_by! { |details| details['cid'] }
      r.each do |details|
        puts "#{details['cid']} -> #{details['orcid']} (authenticated: #{details['oauth_access_token'].blank? ? 'NO' : 'yes'})"
        count += 1
      end
      puts "#{count} ORCIDS(s) listed"

    else
      puts "ERROR: ORCID service returns #{status}, aborting"
    end
  end

  desc "List known local ORCID's"
  task list_local_orcids: :environment do |t, args|

    count = 0
    User.order( :email ).each do |user|
      if user.orcid.blank? == false
        orcid = orcid_from_orcid_url( user.orcid )
        cid = User.cid_from_email( user.email )
        puts "#{cid} -> #{orcid} (authenticated: #{user.orcid_access_token.blank? ? 'NO' : 'yes'})"
        count += 1
      end
    end

    puts "#{count} ORCIDS(s) listed"

  end

  desc "Harvest remote ORCID's and update the local users"
  task harvest_remote_orcids: :environment do |t, args|

    count = 0
    User.order( :email ).each do |user|

      cid = User.cid_from_email( user.email )
      status, attribs = ServiceClient::OrcidAccessClient.instance.get_attribs_by_cid(cid )
      if ServiceClient::OrcidAccessClient.instance.ok?( status )
        # puts attribs.to_json
        orcid = attribs['orcid']
        puts "#{cid} <- #{orcid}"
        user.orcid = orcid
        user.orcid_access_token = attribs['oauth_access_token']
        user.orcid_refresh_token = attribs['oauth_refresh_token']
        user.orcid_scope = attribs['scope']
        puts user.changes
        if user.changed?
          user.orcid_linked_at = DateTime.parse(attribs['created_at'])
          user.save!
          count += 1
        end
      end
    end
    puts "#{count} user(s) updated"

  end

  desc "Harvest local ORCID's and push to ORCID service"
  task harvest_local_orcids: :environment do |t, args|

     count = 0
     User.order( :email ).each do |user|
       if user.orcid.blank? == false
         orcid = orcid_from_orcid_url( user.orcid )
         cid = User.cid_from_email( user.email )

         puts "Updating ORCID attributes for #{cid} (#{orcid})"
         status = ServiceClient::OrcidAccessClient.instance.set_attribs_by_cid(
             cid,
             orcid,
             user.orcid_access_token,
             user.orcid_refresh_token,
             user.orcid_scope )
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

  desc "Purge unauthenticated local ORCID's"
  task purge_local_orcids: :environment do |t, args|

    count = 0
    User.order( :email ).each do |user|
      if user.orcid.blank? == false && user.orcid_access_token.blank? == true
        user.orcid = nil
        user.save!
        count += 1
      end
    end
    puts "#{count} ORCID(s) purged"

  end

  #desc "Search ORCID; must provide a search pattern, optionally provide a start index and max count"
  #task search_orcid: :environment do |t, args|

  #  search = ARGV[ 1 ]
  #  if search.nil?
  #    puts "ERROR: no search parameter specified, aborting"
  #    next
  #  end

  #  task search.to_sym do ; end

  #  start = ARGV[ 2 ]
  #  if start.nil?
  #    start = "0"
  #  end

  #  task start.to_sym do ; end

  #  max = ARGV[ 3 ]
  #  if max.nil?
  #    max = "100"
  #  end

  #  task max.to_sym do ; end

  #  count = 0
  #  status, r = ServiceClient::OrcidAccessClient.instance.search_orcid( search, start, max )
  #  if ServiceClient::OrcidAccessClient.instance.ok?( status )
  #    r.each do |details|
  #      puts "#{details['last_name']}, #{details['first_name']} (#{details['display_name']}) -> #{details['orcid']}"
  #      count += 1
  #    end
  #    puts "#{count} ORCIDS(s) listed"

  #  else
  #    puts "ERROR: ORCID service returns #{status}, aborting"
  #  end

  #end

  desc "Update ORCID with an activity; must provide the work id; optionally provide author email"
  task update_author_activity: :environment do |t, args|

    work_id = ARGV[ 1 ]
    if work_id.nil?
      puts "ERROR: no work id parameter specified, aborting"
      next
    end

    task work_id.to_sym do ; end

    who = ARGV[ 2 ]
    who = TaskHelpers.default_user_email if who.nil?
    task who.to_sym do ; end

    cid = User.cid_from_email( who )

    work = TaskHelpers.get_work_by_id( work_id )
    if work.nil?
      puts "ERROR: work #{work_id} does not exist, aborting"
      next
    end

    suitable, why = work_suitable_for_orcid_activity( cid, work )
    if suitable == false
      puts "ERROR: work #{work_id} is unsuitable to report as activity for #{cid} (#{why}), aborting"
      next
    end

    status, update_code = ServiceClient::OrcidAccessClient.instance.set_activity_by_cid( cid, work )
    if ServiceClient::OrcidAccessClient.instance.ok?( status )
      if work.orcid_put_code.blank?
        work.orcid_put_code = update_code
        work.save!
      end

      puts "Success; work #{work_id} reported as activity for #{cid} (update code #{update_code})"
    else
      puts "ERROR: ORCID service returns #{status}, aborting"
    end

  end


  desc "Update ORCID with all author activity; optionally provide the author email"
  task update_all_author_activity: :environment do |t, args|

    who = ARGV[ 1 ]
    who = TaskHelpers.default_user_email if who.nil?
    task who.to_sym do ; end

    cid = User.cid_from_email( who )

    count = 0
    reported = 0
    errors = 0
    GenericWork.search_in_batches( { depositor: who } ) do |group|
      group.each do |lw_solr|
        begin
          work = GenericWork.find( lw_solr['id'] )
          suitable, why = work_suitable_for_orcid_activity( cid, work )
          if suitable == false
            puts "ERROR: work #{work.id} is unsuitable to report as activity for #{cid} (#{why})"
            next
          end

          status, update_code = ServiceClient::OrcidAccessClient.instance.set_activity_by_cid( cid, work )
          if ServiceClient::OrcidAccessClient.instance.ok?( status )
            if work.orcid_put_code.blank?
              work.orcid_put_code = update_code
              work.save!
            end

            reported += 1
            puts "Success; work #{work.id} reported as activity for #{cid} (update code #{update_code})"
          else
            errors += 1
            puts "ERROR: ORCID service returns #{status} for work #{work.id} reported as activity for #{cid}"
          end

        rescue => e
          errors += 1
          puts e
        end
      end
      count += group.size
    end

    puts "Processed #{count} work(s), #{reported} reported, #{errors} errors"

  end

  desc "Update ORCID with all activity"
  task update_all_activity: :environment do |t, args|

    count = 0
    reported = 0
    errors = 0
    GenericWork.search_in_batches( { } ) do |group|
      group.each do |lw_solr|
        begin
          work = GenericWork.find( lw_solr['id'] )

          depositor_cid = User.cid_from_email( work.depositor )

          suitable, why = work_suitable_for_orcid_activity( depositor_cid, work )
          if suitable == false
            puts "ERROR: work #{work.id} is unsuitable to report as activity for #{depositor_cid} (#{why})"
            next
          end

          status, update_code = ServiceClient::OrcidAccessClient.instance.set_activity_by_cid( depositor_cid, work )
          if ServiceClient::OrcidAccessClient.instance.ok?( status )
            if work.orcid_put_code.blank?
              work.update orcid_put_code: update_code, orcid_status: GenericWork.complete_orcid_status
            end

            reported += 1
            puts "Success; work #{work.id} reported as activity for #{depositor_cid} (update code #{update_code})"
          else
            errors += 1
            puts "ERROR: ORCID service returns #{status} for work #{work.id} reported as activity for #{depositor_cid}"
          end

        rescue => e
          errors += 1
          puts e
        end
      end
      count += group.size
    end

    puts "Processed #{count} work(s), #{reported} reported, #{errors} errors"

  end



  desc "Report ORCID status; optionally provide the depositor email"
  task report_status: :environment do |t, args|

    who = ARGV[ 1 ]
    if who
      task who.to_sym do ; end
    end

    count = 0
    reported = 0
    pending = 0
    errors = 0
    GenericWork.search_in_batches( { } ) do |group|
      group.each do |lw_solr|
        begin

          depositor = lw_solr[ Solrizer.solr_name( 'depositor' ) ]
          depositor = depositor[ 0 ] if depositor.present?
          next if who && who != depositor

          count += 1

          status = lw_solr[ Solrizer.solr_name( 'orcid_status' ) ]
          status = status[ 0 ] if status.present?
          if status == 'complete'
            puts "Work #{lw_solr['id']}: already reported (depositor #{User.cid_from_email( depositor )})"
            reported += 1
            next
          end

          work = GenericWork.find( lw_solr['id'] )
          depositor_cid = User.cid_from_email( work.depositor )

          suitable, why = work_suitable_for_orcid_activity( depositor_cid, work )
          if suitable == false
            puts "Work #{work.id}: unsuitable to report as activity for #{depositor_cid} (#{why})"
            next
          end

          user = User.find_by_email( work.depositor )
          if user.present?
            if user.orcid.present? && user.orcid_access_token.present?
              pending += 1
              puts "Work #{work.id}: will be reported for #{depositor_cid}"
            else
              puts "Work #{work.id}: missing depositor ORCID/OAUTH for #{depositor_cid}"
            end

          else
            errors += 1
            puts "Work #{work.id}: missing depositor record for #{depositor_cid}"
          end

        rescue => ex
          errors += 1
          puts ex
        end
      end
    end

    puts "Processed #{count} work(s), #{pending} pending, #{reported} already reported, #{errors} errors"

  end

  end   # namespace orcid

end   # namespace libraoc

#
# end of file
#
