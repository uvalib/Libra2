#
# Some helper tasks to manage DOI submission
#

require_dependency 'libra2/lib/serviceclient/entity_id_client'

namespace :libra2 do

  namespace :doi do

  desc "Create new DOI for work; must provide the work id"
  task assign_new_doi: :environment do |t, args|

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

    if work.identifier.empty? == false
      puts "WARNING: work #{work_id} already has a DOI (#{work.identifier}), removing it"
      #status = ServiceClient::EntityIdClient.instance.remove( work )
      #if ServiceClient::EntityIdClient.instance.ok?( status ) == false
      #  puts "ERROR: remove DOI request returns #{status}, aborting"
      #  next
      #end
    end

    # mint a new DOI
    status, id = ServiceClient::EntityIdClient.instance.newid( work )
    if ServiceClient::EntityIdClient.instance.ok?( status ) == false
      puts "ERROR: new DOI request returns #{status}, aborting"
      next
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
        next
      end
    end

    puts "New DOI assigned successfully (#{work.identifier})"

  end

  end   # namespace doi

end   # namespace libra2

#
# end of file
#
