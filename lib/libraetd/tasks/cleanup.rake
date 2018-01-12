namespace :libraetd do
  namespace :cleanup do

    desc "runs unescape to clean up characters like &gt; &quot; etc."
    task unescape_html: :environment do
      successes = 0
      errors = 0
      fields = [:title, :description]

      GenericWork.search_in_batches( {} ) do |group|
        group.each do |w|
          begin
            print "."
            work = GenericWork.find( w['id'] )
            fields.each do |field|
              attrib = work[field].first
              cleaned = CGI.unescapeHTML attrib
              # try array, then singular field
              puts field, cleaned
              begin
                work[field] = [cleaned]
              rescue
                work[field] = cleaned
              end

            end
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
  end
end
