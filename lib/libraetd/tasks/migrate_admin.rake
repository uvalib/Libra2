#
# Some helper tasks to edit works
#

# pull in the helpers
require_dependency 'libraetd/tasks/task_helpers'
include TaskHelpers

namespace :libraetd do

namespace :migrate do

    desc "Migration to ordered fields (keyword, related_url, sponsoring_agency)"
    task ordered_fields: :environment do |t, args|

      successes = 0
      errors = 0
      GenericWork.search_in_batches( {} ) do |group|
        group.each do |w|
          begin
            print "."

            work = GenericWork.find( w['id'] )

            # this will migrate the fields...
            work.keyword = work.keyword
            work.related_url = work.related_url
            work.sponsoring_agency = work.sponsoring_agency

            work.save!

            successes += 1
          rescue => ex
            puts ex
            errors += 1
          end
        end
      end

      puts "done"
      puts "Processed #{successes} work(s), #{errors} error(s) encountered"

    end

    #desc "Migrate date format for all works."
    #task date_format: :environment do |t, args|

    #  count = 0
    #  works = GenericWork.all
    #  works.each { |work|
    #    changed_create, date_created = convert_date_format( work.date_created )
    #    changed_published, date_published = convert_date_format( work.date_published )

    #    if changed_create || changed_published
    #      if changed_create
    #        puts "Updating work #{work.id} date_created from #{work.date_created} -> #{date_created}"
    #        work.date_created = date_created
    #      end

    #      if changed_published
    #        puts "Updating work #{work.id} date_published from #{work.date_published} -> #{date_published}"
    #        work.date_published = date_published
    #      end

    #      count += 1
    #      work.save!
    #    end
    #  }

    #  puts "#{count} works updated"
    #end

    desc "Migrate advisor format for all works."
    task advisor_format: :environment do |t, args|

      count = 0
      GenericWork.search_in_batches( { } ) do |group|
        TaskHelpers.batched_process_solr_works( group, &method( :advisor_fix_generic_work_callback ) )
        count += group.size
      end

      puts "Processed #{count} work(s)"
    end

    desc "Refresh by re-saving each GenericWork"
    task refresh: :environment do |t, args|

      successes = 0
      errors = 0
      GenericWork.search_in_batches( {} ) do |group|
        group.each do |w|
          begin
            print "."
            work = GenericWork.find( w['id'] )
            work.save!

            successes += 1
          rescue => ex
            puts "EXCEPTION: #{ex}"
            errors += 1
          end
        end
      end

      puts "done"
      puts "Processed #{successes} work(s), #{errors} error(s) encountered"

    end

    desc "Fix missing timestamp on admin notes"
    task fix_admin_notes: :environment do |t, args|

      count = 0
      successes = 0
      errors = 0
      GenericWork.search_in_batches( {} ) do |group|
        group.each do |w|
          begin
            count += 1
            print "."
            work = GenericWork.find( w['id'] )

            if work.admin_notes.blank? == false
              updated = false
              updated_notes = []
              work.admin_notes.each do |note|
                if /^Thesis originally/.match( note )
                  note = "#{w['system_create_dtsi']} | #{note}"
                  updated = true
                elsif /^This thesis was/.match( note )
                  note = "#{w['system_create_dtsi']} | #{note}"
                  updated = true
                end
                updated_notes << note

              end

              if updated == true
                 work.admin_notes = updated_notes;
                 work.save!
                 successes += 1
              end

            end

          rescue => ex
            puts ex
            errors += 1
          end
        end
      end

      puts "done"
      puts "Processed #{count} work(s), #{successes} work(s) updated successfully, #{errors} error(s) encountered"

    end

    desc "Fix rights"
    task fix_rights: :environment do |t, args|

      count = 0
      successes = 0
      errors = 0
      GenericWork.search_in_batches( {} ) do |group|
        group.each do |w|
          count += 1
          print "."

          if w['rights_tesim'].present?
            current_rights = w['rights_tesim'][ 0 ]
            updated = false
            updated_rights = ""

            if /^None \(users must comply with ordinary copyright law\)$/.match( current_rights )
              updated_rights = 'All rights reserved (no additional license for public reuse)'
              updated = true
            elsif /^Attribution \(CC BY\)/.match( current_rights )
              updated_rights = 'CC-BY (permitting free use with proper attribution)'
              updated = true
            elsif /^None$/.match( current_rights )
              updated_rights = 'All rights reserved (no additional license for public reuse)'
              updated = true
            elsif /^No Rights Reserved \(CC0\)/.match( current_rights )
              updated_rights = 'CC0 (permitting unconditional free use, with or without attribution)'
              updated = true
            end

            if updated == true
              puts "\nUpdating work #{w['id']}: rights \"#{current_rights}\" -> \"#{updated_rights}\"\n"
              begin
                work = GenericWork.find( w['id'] )
                work.rights = [ updated_rights ]
                work.save!
                successes += 1
              rescue => ex
                puts ex
                errors += 1
              end
            end
          end
        end
      end

      puts "done"
      puts "Processed #{count} work(s), #{successes} work(s) updated successfully, #{errors} error(s) encountered"

    end

    desc "Fix rights again"
    task fix_rights_again: :environment do |t, args|

      count = 0
      successes = 0
      errors = 0
      GenericWork.search_in_batches( {} ) do |group|
        group.each do |w|
          count += 1
          print "."

          if w['rights_tesim'].present?
            current_rights = w['rights_tesim'][ 0 ]
            updated = false
            updated_rights = ""

            if /^CC-BY \(permitting free use with proper attribution\)$/.match( current_rights )
              updated_rights = 'Attribution 4.0 International (CC BY)'
              updated = true
            end

            if updated == true
              puts "\nUpdating work #{w['id']}: rights \"#{current_rights}\" -> \"#{updated_rights}\"\n"
              begin
                work = GenericWork.find( w['id'] )
                work.rights = [ updated_rights ]
                work.save!
                successes += 1
              rescue => ex
                puts ex
                errors += 1
              end
            end

          end

        end
      end

      puts "done"
      puts "Processed #{count} work(s), #{successes} work(s) updated successfully, #{errors} error(s) encountered"

    end

    private

    def convert_date_format( date_str )

      return false, date_str if date_str.blank?
      if date_str.match( /\d{2}\/\d{2}\/\d{2}/ )
        dt = date_str.gsub( '/', '-' )
        return true, dt
      end

      return false, date_str
    end

    def advisor_fix_generic_work_callback( work )

      return if work.contributor.blank?

      updated = []
      puts "==> Work: #{work.id}"
      work.contributor.each_with_index do |c, ix|
        tokens = c.split( "\n" )
        if tokens.length == 6
          puts "Correctly formatted adviser fields, ignoring"
          return
        end

        tokens.push('') if tokens.length == 3 # if the last item is empty, the split command will miss it.
        tokens.push('') if tokens.length == 4 # if the last item is empty, the split command will miss it.

        next if all_blank?( tokens )
        adv = TaskHelpers.contributor_fields( ix,
                                              tokens[ 0 ],
                                              tokens[ 1 ],
                                              tokens[ 2 ],
                                              tokens[ 3 ],
                                              tokens[ 4 ] )

        updated << adv

      end
      puts "Updating advisor fields:"
      puts " BEFORE: #{work.contributor}"
      puts " AFTER:  #{updated}"
      work.contributor = updated
      work.save!

    end

    def all_blank?( tokens )
      return tokens[ 0 ].blank? &&
          tokens[ 1 ].blank? &&
          tokens[ 2 ].blank? &&
          tokens[ 3 ].blank? &&
          tokens[ 4 ].blank?
    end

end   # namespace migrate

end   # namespace libraetd

#
# end of file
#
