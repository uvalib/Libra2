namespace :libra2 do

	namespace :logs do
		def get_request_line(input, output)
			of = File.new(output, "w+")
			File.open(input, "r").each_line do |line|
				if line.include?("-- : Started") # This will match the first log line of each request
					of.puts(line)
				end
			end
			of.close
		end

		def convert_file(input, output)
			tmp = "#{output}.tmp"
			strip_non_rails(input, tmp)
			`sort -k1 < #{tmp} > #{output}`
		end

		def strip_non_rails(input, output)
			of = File.new(output, "w+")
			File.open(input, "r").each_line do |line|
				if line.include?("-- :") # get rid of the lines not added by the Libra2 Rails app
					line = line[65,line.length] # get rid of the tacked on stuff that looks like: 2016-07-14T09:49:00-04:00 dockerprod1 docker/49a126baed37[6764]:
					of.puts(line)
				end
			end
			of.close
		end

		desc "Get rid of non-Libra2 items from log file"
		task clean_up: :environment do |t, args|
			log_folder = "#{Rails.root}/log"
			# get_request_line("#{log_folder}/docker1.log", "#{log_folder}/docker1-filtered.log")
			convert_file("#{log_folder}/docker1.log", "#{log_folder}/docker1-filtered.log")
			convert_file("#{log_folder}/docker2.log", "#{log_folder}/docker2-filtered.log")
		end
	end # namespace logs

end # namespace libra2
