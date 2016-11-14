#
# Some helper tasks to manage DOI submission
#

# pull in the helpers
require_dependency 'libra2/tasks/task_helpers'
include TaskHelpers

require_dependency 'libra2/lib/serviceclient/entity_id_client'

namespace :libra2 do

  namespace :doi do

  #
  # list DOIs for all works from the specified user
  #
  desc "List DOI's for all my works; optionally provide depositor email"
  task list_doi_my_works: :environment do |t, args|

     who = ARGV[ 1 ]
     who = TaskHelpers.default_user_email if who.nil?
     task who.to_sym do ; end

     success_count = 0
     GenericWork.where({ depositor: who }).each do |work|
        puts "#{work.id} => #{work.identifier || 'None'} (#{work.is_draft? ? 'draft' : 'published'})"
        success_count += 1
     end

     puts "#{success_count} work(s) listed successfully"

  end

  #
  # get the EZID service metadata for the specified work
  #
  desc "Get EZID metadata for the specified work; must provide the work id"
  task get_ezid_metadata_by_work: :environment do |t, args|

    work_id = ARGV[ 1 ]
    if work_id.nil?
      puts "ERROR: no work id specified, aborting"
      next
    end

    task work_id.to_sym do ; end

    work = TaskHelpers.get_work_by_id( work_id )
    if work.nil?
      puts "ERROR: work #{work_id} does not exist, aborting"
      next
    end

    status, r = ServiceClient::EntityIdClient.instance.metadataget( work.identifier )
    if ServiceClient::EntityIdClient.instance.ok?( status )
      puts r
    else
      puts "ERROR: EZID service returns #{status}, aborting"
    end

  end

  #
  # get the EZID service metadata for the specified DOI
  #
  desc "Get EZID metadata for the specified DOI; must provide the DOI"
  task get_ezid_metadata_by_doi: :environment do |t, args|

    doi = ARGV[ 1 ]
    if doi.nil?
      puts "ERROR: no DOI specified, aborting"
      next
    end

    task doi.to_sym do ; end

    status, r = ServiceClient::EntityIdClient.instance.metadataget( doi )
    if ServiceClient::EntityIdClient.instance.ok?( status )
      puts r
    else
      puts "ERROR: EZID service returns #{status}, aborting"
    end

  end

  #
  # assign a new DOI for the specified work
  #
  desc "Assign a new DOI for the specified work; must provide the work id"
  task assign_doi_to_work: :environment do |t, args|

    work_id = ARGV[ 1 ]
    if work_id.nil?
      puts "ERROR: no work id specified, aborting"
      next
    end

    task work_id.to_sym do ; end

    work = TaskHelpers.get_work_by_id( work_id )
    if work.nil?
      puts "ERROR: work #{work_id} does not exist, aborting"
      next
    end

    if update_work_doi( work )
      puts "New DOI assigned to work #{work.id} (#{work.identifier})"
    end

  end

  #
  # assign a new DOI for all my works
  #
  desc "Assign new DOI's for all my works; optionally provide depositor email"
  task assign_doi_my_works: :environment do |t, args|

    who = ARGV[ 1 ]
    who = TaskHelpers.default_user_email if who.nil?
    task who.to_sym do ; end

    success_count = 0
    error_count = 0

    GenericWork.where({ depositor: who }).each do |work|
       if update_work_doi( work )
          puts "New DOI assigned to work #{work.id} (#{work.identifier})"
          success_count += 1
       else
         error_count += 1
       end
    end

    puts "New DOI's assigned to #{success_count} work(s) successfully; #{error_count} error(s) encountered"

  end

  #
  # assign a new DOI for all my works that do not have them
  #
  desc "Assign new DOI's for all my works that do not have them; optionally provide depositor email"
  task assign_doi_my_unassigned_works: :environment do |t, args|

    who = ARGV[ 1 ]
    who = TaskHelpers.default_user_email if who.nil?
    task who.to_sym do ; end

    success_count = 0
    error_count = 0

    GenericWork.where({ depositor: who }).each do |work|
      if work.identifier.blank?
        if update_work_doi( work )
          puts "New DOI assigned to work #{work.id} (#{work.identifier})"
          success_count += 1
        else
          error_count += 1
        end
      end
    end

    puts "New DOI's assigned to #{success_count} work(s) successfully; #{error_count} error(s) encountered"

  end

  #
  # assign a new DOI for all works
  #
  desc "Bulk assign new DOI's for all works"
  task assign_doi_all_works: :environment do |t, args|

    success_count = 0
    error_count = 0

    GenericWork.all.each do |work|
      if update_work_doi( work )
        puts "New DOI assigned to work #{work.id} (#{work.identifier})"
        success_count += 1
      else
        error_count += 1
      end
    end
    puts "New DOI's assigned to #{success_count} work(s) successfully; #{error_count} error(s) encountered"
  end

  #
  # assign a new DOI for all works that do not have them
  #
  desc "Bulk assign new DOI's for all works"
  task assign_doi_all_unassigned_works: :environment do |t, args|

    success_count = 0
    error_count = 0

    GenericWork.all.each do |work|
      if work.identifier.blank?
        if update_work_doi( work )
          puts "New DOI assigned to work #{work.id} (#{work.identifier})"
          success_count += 1
        else
          error_count += 1
        end
      end
    end
    puts "New DOI's assigned to #{success_count} work(s) successfully; #{error_count} error(s) encountered"
  end

  #
  # resubmit the EZID metadata for the specified work
  #
  desc "Update DOI metadata for the specified work; must provide the work id"
  task update_doi_metadata_by_work: :environment do |t, args|

    work_id = ARGV[ 1 ]
    if work_id.nil?
      puts "ERROR: no work id specified, aborting"
      next
    end

    task work_id.to_sym do ; end

    work = TaskHelpers.get_work_by_id( work_id )
    if work.nil?
      puts "ERROR: work #{work_id} does not exist, aborting"
      next
    end

    if update_work_metadata( work )
      puts "Updated DOI metadata for work #{work.id} (#{work.identifier})"
    end

  end

  #
  # resubmit the EZID metadata for all published works from the specified depositor
  #
  desc "Update DOI metadata for all my submitted works; optionally provide depositor email"
  task update_doi_metadata_my_works: :environment do |t, args|

    who = ARGV[ 1 ]
    who = TaskHelpers.default_user_email if who.nil?
    task who.to_sym do ; end

    success_count = 0
    error_count = 0

    GenericWork.where({ depositor: who }).each do |work|
       if update_work_metadata( work )
          puts "Updated DOI metadata for work #{work.id} (#{work.identifier})"
          success_count += 1
       else
         error_count += 1
       end
    end

    puts "#{success_count} work(s) successfully updated; #{error_count} error(s) encountered"

  end

  #
  # resubmit the EZID metadata for all published works
  #
  desc "Update DOI metadata for all submitted works"
  task update_doi_metadata_all_works: :environment do |t, args|

    success_count = 0
    error_count = 0

    GenericWork.all.each do |work|
      if update_work_metadata( work )
        puts "Updated DOI metadata for work #{work.id} (#{work.identifier})"
        success_count += 1
      else
        error_count += 1
      end
    end
    puts "#{success_count} work(s) successfully updated; #{error_count} error(s) encountered"
  end

  #
  # delete the specified DOI
  #
  desc "Delete the specified DOI; must provide the DOI"
  task delete_by_doi: :environment do |t, args|

    doi = ARGV[ 1 ]
    if doi.nil?
      puts "ERROR: no DOI specified, aborting"
      next
    end

    task doi.to_sym do ; end

    status = ServiceClient::EntityIdClient.instance.remove( doi )
    if ServiceClient::EntityIdClient.instance.ok?( status ) == false
      puts "ERROR: EZID service returns #{status}, aborting"
    else
      puts "DOI successfully deleted"
    end

  end

  #
  # revoke the specified DOI
  #
  desc "Revoke the specified DOI; must provide the DOI"
  task revoke_by_doi: :environment do |t, args|

    doi = ARGV[ 1 ]
    if doi.nil?
      puts "ERROR: no DOI specified, aborting"
      next
    end

    task doi.to_sym do ; end

    status = ServiceClient::EntityIdClient.instance.revoke( doi )
    if ServiceClient::EntityIdClient.instance.ok?( status ) == false
      puts "ERROR: EZID service returns #{status}, aborting"
    else
      puts "DOI successfully revoked"
    end

  end

  #
  # helper methods
  #

  # update the DOI for the supplied work
  def update_work_doi( work )

      if work.identifier.blank? == false
        if work.is_draft? == true
           puts "WARNING: draft work #{work.id} already has a DOI (#{work.identifier}), removing it"
           status = ServiceClient::EntityIdClient.instance.remove( work.identifier )
        else
           puts "WARNING: published work #{work.id} already has a DOI (#{work.identifier}), revoking it"
           status = ServiceClient::EntityIdClient.instance.revoke( work.identifier )
        end

        if ServiceClient::EntityIdClient.instance.ok?( status ) == false
          puts "ERROR: remove/revoke DOI request returns #{status}, continuing anyway"
        end
      end

      # mint a new DOI
      status, id = ServiceClient::EntityIdClient.instance.newid( work )
      if ServiceClient::EntityIdClient.instance.ok?( status ) == false
        puts "ERROR: new DOI request returns #{status}, aborting"
        return false
      end

      # update the identifier
      work.identifier = id
      work.permanent_url = GenericWork.doi_url( id )
      work.save!

     if work.is_draft? == false
        puts "Work is submitted; updating DOI service with final metadata"
        # update the service metadata
        status = ServiceClient::EntityIdClient.instance.metadatasync( work )
        if ServiceClient::EntityIdClient.instance.ok?( status ) == false
          puts "ERROR: metadata update returns #{status}, aborting"
          return false
        end
     end

    return true
  end

  # update the metadata for the supplied work
  def update_work_metadata( work )

    if work.is_draft?
      puts "Work #{work.identifier} is draft... ignoring"
      return false
    else
      status = ServiceClient::EntityIdClient.instance.metadatasync( work )
      if ServiceClient::EntityIdClient.instance.ok?( status ) == false
        puts "ERROR: metadata update returns #{status}, aborting"
        return false
      end
    end
    return true
  end

  end   # namespace doi

end   # namespace libra2

#
# end of file
#
