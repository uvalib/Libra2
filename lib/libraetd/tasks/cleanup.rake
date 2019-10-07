namespace :libraetd do
  namespace :cleanup do

    desc "runs unescape to clean up characters like &gt; &quot; etc."
    task unescape_html: :environment do
      successes = 0
      errors = 0

      GenericWork.search_in_batches( {} ) do |group|
        group.each do |w|
          begin
            print "."

            title = ''
            cleaned_title = ''
            abstract = ''
            cleaned_abstract = ''
            update = false

            if w['title_tesim'].present?
              title = w['title_tesim'][ 0 ]
              cleaned_title = CGI.unescapeHTML title
              if title != cleaned_title
                puts "\nID: #{w['id']}"
                puts "old title: #{title}"
                puts "new title: #{cleaned_title}"
                 update = true
              end
            end

            if w['description_tesim'].present?
              abstract = w['description_tesim'][ 0 ]
              cleaned_abstract = CGI.unescapeHTML abstract
              if abstract != cleaned_abstract
                puts "\nID: #{w['id']}"
                puts "old abstract: #{abstract}"
                puts "new abstract: #{cleaned_abstract}"
                 update = true
              end
            end

            if update == true

              work = GenericWork.find( w['id'] )
              work.title = [cleaned_title] if cleaned_title.present?
              work.description = cleaned_abstract if cleaned_abstract.present?
              work.save!
            end

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

    desc "Normalizes degree names in given csv"
    task(:normalize_degrees, [:csv_path] => :environment ) do |t, args|
      require 'csv'
      log = ActiveSupport::Logger.new('hostfs/logs/degree_cleanup.log')

      degrees = ServiceClient::DepositRegClient.instance.list_deposit_options( ).last['degrees']


      CSV.foreach(args.csv_path, headers: true) do |row|
        begin
          id = row['Id'].strip
          work = GenericWork.where(id: id).first
          if work

            degree = row['Degree']

            if degrees.include? degree
              if work.degree != degree
                work.degree = degree
                saved = work.save
                log.info "#{id} - Degree: #{degree} - Saved: #{saved}"
              else
                log.info "#{id} - Degree unchanged"
              end
            else
              log.warn "#{id} - Degree '#{degree}' not included in the list of degrees."
            end

          else
            log.warn "#{id} - Not found"
          end
          print '.'
        rescue NoMethodError => e
          log.error e
          puts e
        end
      end
    end
    desc "New Department names in given csv"
    task(:apply_new_departments, [:csv_path] => :environment ) do |t, args|
      require 'csv'
      log = ActiveSupport::Logger.new('hostfs/logs/updated_departments.log')

      CSV.foreach(args.csv_path, headers: true) do |row|
        begin
          id, csv_department = row.fields
          work = GenericWork.where(id: id).first
          if work
            if work.department != csv_department
              old_dept = work.department
              work.department = csv_department
              saved = work.save
              log.info "#{id} - old dept:[#{old_dept}] new dept:[#{csv_department}] - Saved: #{saved}"
            else
              log.info "#{id} - Dept unchanged"
            end

          else
            log.warn "#{id} - Not found"
          end
          print '.'
        rescue NoMethodError => e
          log.error e
          puts e
        end
      end
    end
  end
end
