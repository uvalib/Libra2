# pull in the helpers
require_dependency 'libraetd/tasks/task_helpers'
include TaskHelpers

namespace :libraetd do

  namespace :fileset do

    desc "Display all filesets"
    task display_all_filesets: :environment do |t, args|

      count = 0
      FileSet.search_in_batches( {} ) do |group|
        group.each do |fs_solr|

          created = fs_solr[ 'date_uploaded_dtsi' ]
          created = 'UNKNOWN' if created.blank?

          title = fs_solr[ Solrizer.solr_name( 'title' ) ]
          title = title[ 0 ] if title.present?
          title = '(blank)' if title.blank?

          label = fs_solr[ Solrizer.solr_name( 'label' ) ]
          label = label[ 0 ] if label.present?
          label = '(blank)' if label.blank?

          puts "#{fs_solr['id']}: #{created} #{title}/#{label}"
        end

        count += group.size
      end

      puts "Displayed #{count} fileset(s)"
    end

    desc "List fileset by id; must provide the fileset id"
    task list_by_id: :environment do |t, args|

      fileset_id = ARGV[ 1 ]
      if fileset_id.nil?
        puts "ERROR: no fileset id specified, aborting"
        next
      end

      task fileset_id.to_sym do ; end

      fileset = TaskHelpers.get_fileset_by_id( fileset_id )
      if fileset.nil?
        puts "ERROR: fileset #{fileset_id} does not exist, aborting"
        next
      end

      TaskHelpers.show_fileset(fileset )
    end

  end # namespace fileset

end # namespace libraetd

