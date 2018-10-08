#
# Some helper tasks to SOLR index regeneration
#

require 'active_fedora/solr_service'

namespace :libraetd do

  namespace :solr do

  desc "Regenerate the SOLR index from a list of work URI's; must provide file name and optional start index number"
  task solr_regenerate: :environment do |t, args|

    filename = ARGV[ 1 ]
    if filename.nil?
      puts "ERROR: no file name provided, aborting"
      next
    end

    task filename.to_sym do ; end

    start = ARGV[ 2 ]
    if start.nil?
      start = "0"
    end

    task start.to_sym do ; end

    start_ix = start.to_i
    start_ix = 0 if start_ix.to_s != start

    total_count = 0
    File.open( filename ).each do |line|
      total_count += 1
    end

    # basically taken from active_fedora/indexing.rb

    batch_size = 100
    batch = []
    soft_commit = true

    successes = 0
    errors = 0
    index = 0
    File.open( filename ).each do |line|

      if start_ix > index
        puts "IGNORING item #{index + 1} of #{total_count}..."
        index += 1
        next
      end

      puts "processing item #{index + 1} of #{total_count}..."

      encoded_url = URI.encode(line)
      begin
        batch << ActiveFedora::Base.find(ActiveFedora::Base.uri_to_id(encoded_url)).to_solr
        successes += 1
      rescue Ldp::Gone
        puts "ERROR: Ldp:Gone (#{line})"
        errors += 1
      end

      index += 1

      if (batch.count % batch_size).zero?
        puts "SOLR soft commit..."
        ActiveFedora::SolrService.add( batch, softCommit: soft_commit )
        batch.clear
      end

    end

    if batch.present?
      puts "SOLR soft commit..."
      ActiveFedora::SolrService.add( batch, softCommit: soft_commit )
      batch.clear
    end

    puts "Doing final SOLR hard commit..."
    ActiveFedora::SolrService.commit

    puts "#{total_count} items processed. #{successes} re-indexed, #{errors} errors, #{start_ix} ignored"

  end

  def extract_and_reindex_item( uri )
    ActiveFedora::Base.find( ActiveFedora::Base.uri_to_id(uri), cast: true).update_index
  end

  end   # namespace solr

end   # namespace libraetd

#
# end of file
#
