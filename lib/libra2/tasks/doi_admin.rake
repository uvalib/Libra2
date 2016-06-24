#
# Some helper tasks to manage DOI submission
#

require_dependency 'libra2/lib/serviceclient/entity_id_client'

namespace :libra2 do

  namespace :doi do

  default_user = "dpg3k@virginia.edu"

  desc "Get EZID metadata for the specified work; must provide the work id"
  task get_ezid_metadata_by_work: :environment do |t, args|

    work_id = ARGV[ 1 ]
    if work_id.nil?
      puts "ERROR: no work id specified, aborting"
      next
    end

    task work_id.to_sym do ; end

    work = nil
    begin
      work = GenericWork.find( work_id )
    rescue => e
    end

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

  desc "Assign a new DOI for the specified work; must provide the work id"
  task assign_doi_to_work: :environment do |t, args|

    work_id = ARGV[ 1 ]
    if work_id.nil?
      puts "ERROR: no work id specified, aborting"
      next
    end

    task work_id.to_sym do ; end

    work = nil
    begin
       work = GenericWork.find( work_id )
    rescue => e
    end

    if work.nil?
      puts "ERROR: work #{work_id} does not exist, aborting"
      next
    end

    if update_work_doi( work )
      puts "New DOI assigned to work #{work.id} (#{work.identifier})"
    end

  end

  desc "Assign new DOI's for all my works; optionally provide depositor email"
  task assign_doi_my_works: :environment do |t, args|

    who = ARGV[ 1 ]
    who = default_user if who.nil?
    task who.to_sym do ; end

    count = 0
    GenericWork.all.each do |work|
      if work.is_mine?( who )
        if update_work_doi( work )
          puts "New DOI assigned to work #{work.id} (#{work.identifier})"
        end
        count += 1
      end
    end

    puts "New DOI's assigned to #{count} works successfully"

  end

  desc "Bulk assign new DOI's for all works"
  task assign_doi_all_works: :environment do |t, args|

    count = 0
    GenericWork.all.each do |work|
      if update_work_doi( work )
        puts "New DOI assigned to work #{work.id} (#{work.identifier})"
      end
      count += 1
    end
    puts "New DOI's assigned to #{count} works successfully"
  end

  desc "Update DOI metadata for the specified work; must provide the work id"
  task update_doi_metadata_by_work: :environment do |t, args|

    work_id = ARGV[ 1 ]
    if work_id.nil?
      puts "ERROR: no work id specified, aborting"
      next
    end

    task work_id.to_sym do ; end

    work = nil
    begin
      work = GenericWork.find( work_id )
    rescue => e
    end

    if work.nil?
      puts "ERROR: work #{work_id} does not exist, aborting"
      next
    end

    if update_work_metadata( work )
      puts "Updated DOI metadata for work #{work.id} (#{work.identifier})"
    end

  end

  desc "Update DOI metadata for all my submitted works; optionally provide depositor email"
  task update_doi_metadata_my_works: :environment do |t, args|

    who = ARGV[ 1 ]
    who = default_user if who.nil?
    task who.to_sym do ; end

    count = 0
    GenericWork.all.each do |work|
      if work.is_mine?( who )
        if update_work_metadata( work )
          puts "Updated DOI metadata for work #{work.id} (#{work.identifier})"
          count += 1
        end
      end
    end

    puts "#{count} work(s) successfully updated"

  end

  desc "Update DOI metadata for all submitted works"
  task update_doi_metadata_all_works: :environment do |t, args|

    count = 0
    GenericWork.all.each do |work|
      if update_work_metadata( work )
        puts "Updated DOI metadata for work #{work.id} (#{work.identifier})"
        count += 1
      end
    end
    puts "#{count} work(s) successfully updated"
  end

  # update the DOI for the supplied work
  def update_work_doi( work )

      if work.identifier.nil? == false && work.identifier.empty? == false
        puts "WARNING: work #{work.id} already has a DOI (#{work.identifier}), removing it"
        #status = ServiceClient::EntityIdClient.instance.remove( work )
        #if ServiceClient::EntityIdClient.instance.ok?( status ) == false
        #  puts "ERROR: remove DOI request returns #{status}, aborting"
        #  return false
        #end
      end

      # mint a new DOI
      status, id = ServiceClient::EntityIdClient.instance.newid( work )
      if ServiceClient::EntityIdClient.instance.ok?( status ) == false
        puts "ERROR: new DOI request returns #{status}, aborting"
        return false
      end

      # update the identifier
      work.identifier = id
      work.permanent_url = work.doi_url( id )
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
