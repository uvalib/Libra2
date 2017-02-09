#
# Tasks to manage ingest of legacy Libra content
#

# pull in the helpers
require_dependency 'libra2/tasks/ingest_helpers'
include IngestHelpers

namespace :libra2 do

  namespace :ingest do

  #
  # ingest content
  #
  desc "Ingest new Libra content; must provide the ingest directory; optionally provide the start index"
  task new_content: :environment do |t, args|

    ingest_dir = ARGV[ 1 ]
    if ingest_dir.nil?
      puts "ERROR: no ingest directory specified, aborting"
      next
    end
    task ingest_dir.to_sym do ; end

    start = ARGV[ 2 ]
    if start.nil?
      start = "0"
    end
    task start.to_sym do ; end

    start_ix = start.to_i
    start_ix = 0 if start_ix.to_s != start

    # load depositor information
    depositor = Helpers::EtdHelper::lookup_user( IngestHelpers::DEFAULT_DEPOSITOR )
    if depositor.nil?
      puts "ERROR: Cannot locate depositor info (#{IngestHelpers::DEFAULT_DEPOSITOR})"
      next
    end

    user = User.find_by_email( depositor.email )
    if user.nil?
      puts "ERROR: Cannot lookup depositor info (#{depositor.email})"
      next
    end

    # get the list of items to be ingested
    ingests = IngestHelpers.get_ingest_list( ingest_dir )
    if ingests.empty?
      puts "ERROR: ingest directory does not contain contains any items, aborting"
      next
    end

    success_count = 0
    error_count = 0
    ingests.each_with_index do | filename, ix |
      next if ix < start_ix
      ok = ingest_new_content( user, File.join( ingest_dir, filename ) )
      ok == true ? success_count += 1 : error_count += 1
    end
    puts "#{success_count} item(s) processed successfully, #{error_count} error(s) encountered"

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
    ingests = IngestHelpers.get_ingest_list(ingest_dir )
    if ingests.empty?
      puts "ERROR: ingest directory does not contain contains any items, aborting"
      next
    end

    ingests.each_with_index do | dirname, ix |
      IngestHelpers.clear_ingest_id(File.join(ingest_dir, dirname ) )
    end

    puts "done"
  end

  #
  # helpers
  #

  #
  # add new content to an existing metadata record
  #
  def ingest_new_content( depositor, filename )

     ingest_file = filename.gsub( '.xml', '' )
     puts "Ingesting #{ingest_file} ..."

     work_id = IngestHelpers.get_ingest_id( filename )
     if work_id.blank?
       puts "ERROR: #{filename} has no ingest id, continuing anyway"
       return false
     end

     work = TaskHelpers.get_work_by_id( work_id )
     if work.nil?
       puts "ERROR: work #{work_id} does not exist, continuing anyway"
       return false
     end

     # and upload the file
     fileset = TaskHelpers.upload_file( depositor, work, ingest_file, ingest_file )
     fileset.date_uploaded = DateTime.now
     fileset.save!

     return true
  end

  end   # namespace ingest

end   # namespace libra2

#
# end of file
#
