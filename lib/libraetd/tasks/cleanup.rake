namespace :libraetd do
  namespace :cleanup do

    desc "runs unescape to clean up characters like &gt; &quot; etc."
    task unescape_html: :environment do
      successes = 0
      errors = 0

      GenericWork.search_in_batches( {} ) do |group|
        group.each do |w|
          begin
            puts w['id']
            work = GenericWork.find( w['id'] )
            title = work['title'].first
            cleaned_title = CGI.unescapeHTML title
            work.title = [cleaned_title]
            puts "title:", title, cleaned_title


            abstract = work['description']
            cleaned_abstract = CGI.unescapeHTML abstract
            work.description = cleaned_abstract
            puts "abstract:", abstract, cleaned_abstract

            if (title != cleaned_title) || (abstract != cleaned_abstract)
              work.save!
              puts 'saved'
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
  end
end
