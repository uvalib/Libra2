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
            work = GenericWork.find( w['id'] )
              title = work['title'].first
              cleaned = CGI.unescapeHTML title
              work.title = [cleaned]
              puts "title:", title, cleaned

              abstract = work['description']
              cleaned = CGI.unescapeHTML abstract
              work.description = cleaned
              puts "abstract:", abstract, cleaned

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
