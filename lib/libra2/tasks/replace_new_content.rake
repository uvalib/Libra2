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
  desc "Ingest new Libra content; must provide the ingest directory and the replacement directory"
  task replace_new_content: :environment do |t, args|

    ingest_dir = ARGV[ 1 ]
    if ingest_dir.nil?
      puts "ERROR: no ingest directory specified, aborting"
      next
    end
    task ingest_dir.to_sym do ; end

    replacement_dir = ARGV[ 2 ]
    if replacement_dir.nil?
      puts "ERROR: no replacement directory specified, aborting"
      next
    end
    task replacement_dir.to_sym do ; end

    #start = ARGV[ 2 ]
    #if start.nil?
    #  start = "0"
    #end
    #task start.to_sym do ; end

    #start_ix = start.to_i
    #start_ix = 0 if start_ix.to_s != start

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
    replace_count = 0
    total = ingests.size
    ingests.each_with_index do | filename, ix |
      #next if ix < start_ix
      ok, replaced = replace_new_content( user, ingest_dir, replacement_dir, filename, ix + 1, total )
      ok == true ? success_count += 1 : error_count += 1
      replace_count += 1 if replaced == true
      break if ENV[ 'MAX_COUNT' ] && ENV[ 'MAX_COUNT' ].to_i == ( success_count + error_count )
    end
    puts "#{success_count} item(s) processed successfully, #{replace_count} asset(s) replaced, #{error_count} error(s) encountered"

  end

  #
  # helpers
  #

  #
  # replace content for an existing metadata record
  #
  def replace_new_content( depositor, ingest_dirname, replace_dirname, workset_filename, current, total )

     replaced = false
     filename = File.join( ingest_dirname, workset_filename )
     _, asset_filenames = IngestHelpers.load_workset( filename )

     puts "Processing #{current} of #{total}: #{filename} ..."

     work_id = IngestHelpers.get_ingest_id( filename )
     if work_id.blank?
       puts "ERROR: #{filename} has no ingest id, continuing anyway"
       return false, replaced
     end

     work = TaskHelpers.get_work_by_id( work_id )
     if work.nil?
       puts "ERROR: work #{work_id} does not exist, continuing anyway"
       return false, replaced
     end

     asset_filenames.each_with_index do |f, ix|
        puts "  checking asset #{ix + 1} of #{asset_filenames.length}: #{f}"

        # handle dry running
        next if ENV[ 'DRY_RUN' ]

        replacement_filename = File.join( replace_dirname, f )
        if File.exist?( replacement_filename ) == true
          puts "  located replacement: #{replacement_filename}"

          # delete the existing version if we can find it
          work.file_sets.each do |fs|
            if fs.label == f
               TaskHelpers.delete_fileset( depositor, fs )
               break
            end
          end

          # and upload the replacement file
          fileset = TaskHelpers.upload_file( depositor, work, replacement_filename, f )
          fileset.date_uploaded = DateTime.now
          fileset.save!

          replaced = true
        end

     end

     return true, replaced
  end

  end   # namespace ingest

end   # namespace libra2

#
# end of file
#
