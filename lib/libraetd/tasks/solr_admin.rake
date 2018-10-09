#
# Some helper tasks to SOLR index regeneration
#

require 'active_fedora/solr_service'

namespace :libraetd do

  namespace :solr do

  #
  # NOTE: this should be driven from a list of URI's provided by a Fedora extract.
  #
  # Here are the comments from Mike D who did the extract for me.
  #
  # My methodology was to hit the index with the following query (recursively):
  #
  #  PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
  #  PREFIX  fedora3: <info:fedora/fedora-system:def/model#>
  #  PREFIX fedora: <http://fedora.info/definitions/v4/repository#>
  #  SELECT ?uri ?model
  #  WHERE {
  #    ?uri fedora:hasParent <http://fedora01.lib.virginia.edu:8080/fcrepo/rest/libra2/prod> .
  #  }
  #
  #  http://fedora01.lib.virginia.edu:8080/fuseki/dataset.html?tab=query&ds=/fcrepo
  #
  # After the extract, I filtered out all file URI's as these do not go into SOLR.
  #
  desc "Regenerate the SOLR index from a list of URI's; must provide file name and optional start index number"
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
    error_uris = []

    successes = 0
    index = 0
    File.open( filename ).each do |line|

      line.chomp!

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
        error_uris << line
      rescue ActiveFedora::ObjectNotFoundError
        puts "ERROR: ActiveFedora::ObjectNotFoundError (#{line})"
        error_uris << line
      rescue Errno::ENETDOWN
        puts "ERROR: Errno::ENETDOWN (#{line})"
        error_uris << line
      rescue Faraday::TimeoutError
        puts "ERROR: Faraday::TimeoutError (#{line})"
        error_uris << line
      rescue Mysql2::Error
        puts "ERROR: Mysql2::Error (#{line})"
        error_uris << line
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

    puts "SOLR hard commit..."
    ActiveFedora::SolrService.commit

    puts "#{total_count} items processed. #{successes} re-indexed, #{error_uris.count} errors, #{start_ix} ignored"
    if error_uris.present?
      error_uris.each_with_index do |ix, uri|
        puts "ERROR #{ix + 1}: #{uri}"
      end
    end

  end

  end   # namespace solr

end   # namespace libraetd

#
# end of file
#
