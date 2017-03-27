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

      puts "Listed #{count} new ingested work(s)"
    end
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

      puts "Listed #{count} legacy ingested work(s)"
    end

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

      # only finalize draft items...
      if work.is_draft?
         puts "Finalizing #{ix + 1} of #{ingests.length} (#{work_id})..."
         work.draft = 'false'

         if update_work_unassigned_doi( work ) == true
            count += 1
         end

      else
        puts "Work #{ix + 1} of #{ingests.length} (#{work_id}) already finalized, ignoring"
      end

    end

    puts "Finalized #{count} of #{ingests.length} ingest work(s)"
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

      # only finalize draft items...
      if work.is_draft?
        puts "Finalizing #{ix + 1} of #{ingests.length} (#{work_id})..."
        work.draft = 'false'

        if update_work_unassigned_doi( work ) == true
          count += 1
        end

      else
        puts "Work #{ix + 1} of #{ingests.length} (#{work_id}) already finalized, ignoring"
      end

    end

    puts "Finalized #{count} of #{ingests.length} ingest work(s)"
  end

  end   # namespace ingest

end   # namespace libra2

#
# end of file
#
