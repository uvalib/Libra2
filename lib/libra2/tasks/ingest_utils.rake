#
# Tasks to manage ingest of legacy Libra metadata
#

# pull in the helpers
require_dependency 'libra2/tasks/ingest_helpers'
include IngestHelpers

namespace :libra2 do

  namespace :ingest do

  desc "Enumerate new ingested items"
  task new_list: :environment do |t, args|

    count = 0
    GenericWork.search_in_batches( {} ) do |group|
      group.each do |gw_solr|

        begin
          gw = GenericWork.find( gw_solr['id'] )
          if gw.is_ingested_thesis?
            puts "#{gw.work_source} #{gw.identifier || 'None'}"
            count += 1
          end
        rescue => e
        end

      end

    end
    puts "Listed #{count} new ingested work(s)"
  end


  desc "Enumerate legacy ingested items"
  task legacy_list: :environment do |t, args|

    count = 0
    GenericWork.search_in_batches( {} ) do |group|
      group.each do |gw_solr|

        begin
           gw = GenericWork.find( gw_solr['id'] )
           if gw.is_legacy_thesis?
             puts "#{gw.work_source} #{gw.identifier || 'None'}"
             count += 1
           end
        rescue => e
        end

      end
    end
    puts "Listed #{count} legacy ingested work(s)"

  end

  desc "Purge new ingest ids; must provide the ingest directory"
  task purge_new_ingest_id: :environment do |t, args|

    ingest_dir = ARGV[ 1 ]
    if ingest_dir.nil?
      puts "ERROR: no ingest directory specified, aborting"
      next
    end
    task ingest_dir.to_sym do ; end

    # get the list of items to be ingested
    ingests = IngestHelpers.get_ingest_list( ingest_dir )
    if ingests.empty?
      puts "ERROR: ingest directory does not contain contains any items, aborting"
      next
    end

    count = 0
    ingests.each_with_index do | filename, ix |
      IngestHelpers.clear_ingest_id(File.join(ingest_dir, filename ) )
      count += 1
    end

    puts "Purged #{count} new ingest id(s)"
  end

  desc "Purge legacy ingest ids; must provide the ingest directory"
  task purge_legacy_ingest_id: :environment do |t, args|

    ingest_dir = ARGV[ 1 ]
    if ingest_dir.nil?
      puts "ERROR: no ingest directory specified, aborting"
      next
    end
    task ingest_dir.to_sym do ; end

    # get the list of items to be ingested
    ingests = IngestHelpers.get_legacy_ingest_list( ingest_dir )
    if ingests.empty?
      puts "ERROR: ingest directory does not contain contains any items, aborting"
      next
    end

    count = 0
    ingests.each_with_index do | dirname, ix |
      IngestHelpers.clear_legacy_ingest_id(File.join(ingest_dir, dirname ) )
      count += 1
    end

    puts "Purged #{count} legacy ingest id(s)"
  end

  desc "Finalize new ingest works; must provide the ingest directory"
  task finalize_new_ingests: :environment do |t, args|

    ingest_dir = ARGV[ 1 ]
    if ingest_dir.nil?
      puts "ERROR: no ingest directory specified, aborting"
      next
    end
    task ingest_dir.to_sym do ; end

    # get the list of items to be ingested
    ingests = IngestHelpers.get_ingest_list( ingest_dir )
    if ingests.empty?
      puts "ERROR: ingest directory does not contain contains any items, aborting"
      next
    end

    count = 0
    errors = 0
    ingests.each_with_index do | filename, ix |
      work_id = IngestHelpers.get_ingest_id( File.join( ingest_dir, filename ) )

      if work_id.blank?
        puts "ERROR: no work id for #{filename}, continuing anyway"
        next
      end

      work = TaskHelpers.get_work_by_id( work_id )
      if work.nil?
        puts "ERROR: work #{work_id} does not exist, continuing anyway"
        next
      end

      # only finalize items without DOI's...
      if work.identifier.blank?
         puts "Finalizing #{ix + 1} of #{ingests.length} (#{work_id})..."

         if update_work_unassigned_doi( work ) == true
            count += 1
         else
           errors += 1
         end

      else
        puts "Work #{ix + 1} of #{ingests.length} (#{work_id}) already has a DOI, ignoring"
      end

    end

    puts "Finalized #{count} of #{ingests.length} ingest work(s). #{errors} error(s) encountered."
  end

  desc "Finalize legacy ingest works; must provide the ingest directory"
  task finalize_legacy_ingests: :environment do |t, args|

    ingest_dir = ARGV[ 1 ]
    if ingest_dir.nil?
      puts "ERROR: no ingest directory specified, aborting"
      next
    end
    task ingest_dir.to_sym do ; end

    # get the list of items to be ingested
    ingests = IngestHelpers.get_legacy_ingest_list( ingest_dir )
    if ingests.empty?
      puts "ERROR: ingest directory does not contain contains any items, aborting"
      next
    end

    count = 0
    errors = 0
    ingests.each_with_index do | dirname, ix |
      work_id = IngestHelpers.get_legacy_ingest_id( File.join( ingest_dir, dirname ) )

      if work_id.blank?
        puts "ERROR: no work id for #{File.join( ingest_dir, dirname )}, continuing anyway"
        errors += 1
        next
      end

      work = TaskHelpers.get_work_by_id( work_id )
      if work.nil?
        puts "ERROR: work #{work_id} does not exist, continuing anyway"
        errors += 1
        next
      end

      # only finalize items without DOI's...
      if work.identifier.blank?
        puts "Finalizing #{ix + 1} of #{ingests.length} (#{work_id})..."

        if update_work_unassigned_doi( work ) == true
          count += 1
        else
          errors += 1
        end

      else
        puts "Work #{ix + 1} of #{ingests.length} (#{work_id}) already has a DOI, ignoring"
      end

    end

    puts "Finalized #{count} of #{ingests.length} ingest work(s). #{errors} error(s) encountered."
  end

  desc "Delete new ingest works; must provide the ingest directory"
  task delete_new_ingests: :environment do |t, args|

    ingest_dir = ARGV[ 1 ]
    if ingest_dir.nil?
      puts "ERROR: no ingest directory specified, aborting"
      next
    end
    task ingest_dir.to_sym do ; end

    # get the list of items to be ingested
    ingests = IngestHelpers.get_ingest_list( ingest_dir )
    if ingests.empty?
      puts "ERROR: ingest directory does not contain contains any items, aborting"
      next
    end

    count = 0
    ingests.each_with_index do | filename, ix |
      work_id = IngestHelpers.get_ingest_id( File.join( ingest_dir, filename ) )

      if work_id.blank?
        puts "ERROR: no work id for #{filename}, continuing anyway"
        next
      end

      work = TaskHelpers.get_work_by_id( work_id )
      if work.nil?
        puts "ERROR: work #{work_id} does not exist, continuing anyway"
        next
      end

      delete_generic_work_callback( work )
      count += 1

    end

    puts "Deleted #{count} of #{ingests.length} ingest work(s)"

  end

  desc "Delete legacy ingest works; must provide the ingest directory"
  task delete_legacy_ingests: :environment do |t, args|

    ingest_dir = ARGV[ 1 ]
    if ingest_dir.nil?
      puts "ERROR: no ingest directory specified, aborting"
      next
    end
    task ingest_dir.to_sym do ; end

    # get the list of items to be ingested
    ingests = IngestHelpers.get_legacy_ingest_list( ingest_dir )
    if ingests.empty?
      puts "ERROR: ingest directory does not contain contains any items, aborting"
      next
    end

    count = 0
    ingests.each_with_index do | dirname, ix |
      work_id = IngestHelpers.get_legacy_ingest_id( File.join( ingest_dir, dirname ) )

      if work_id.blank?
        puts "ERROR: no work id for #{filename}, continuing anyway"
        next
      end

      work = TaskHelpers.get_work_by_id( work_id )
      if work.nil?
        puts "ERROR: work #{work_id} does not exist, continuing anyway"
        next
      end

      delete_generic_work_callback( work )
      count += 1

    end

    puts "Deleted #{count} of #{ingests.length} ingest work(s)"
  end

  end   # namespace ingest

end   # namespace libra2

#
# end of file
#
