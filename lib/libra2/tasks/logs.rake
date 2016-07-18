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
			of = File.new(tmp, "w")
			of.close
			input.each { |file|
				strip_non_rails(file, tmp)
			}
			`sort -k1 < #{tmp} > #{tmp}.tmp` #sort by time, since the blocks are sometimes written out of order.
			format_file("#{tmp}.tmp", output)
			`rm #{tmp}`
			`rm #{tmp}.tmp`
		end

		def format_file(input, output)
			of = File.new(output, "w")
			File.open(input, "r").each_line do |line|
				line = "\n" + line if line.include?("INFO -- : Started ") # separate the requests.
				of.puts(line)
			end
			of.close
		end

		def is_noise(line)
			noise = [
				"Looking for edit field partial",
				"[CANCAN]",
				"/healthcheck",
				"HealthcheckController",
				"Completed 200 OK",
				'Usergroups are ["public", "registered"]',
				'Attempted to init base path `libra2/prod`, but it already exists'
			]
			noise.each { |item|
				return true if line.include?(item)
			}
			return false
		end
		def strip_non_rails(input, output)
			of = File.new(output, "a")
			File.open(input, "r").each_line do |line|
				if line.include?("-- :") && !(is_noise(line))
					index = line.index("]:")
					line = line[index+3,line.length] # get rid of the tacked on stuff that looks like: 2016-07-14T09:49:00-04:00 dockerprod1 docker/49a126baed37[6764]:
#					line = "\n" + line if line.include?("INFO -- : Started ") # separate the requests.
					of.puts(line)
				end
			end
			of.close
		end

		desc "Get rid of non-Libra2 items from log file"
		task clean_up: :environment do |t, args|
			log_folder = "#{Rails.root}/log"
			# get_request_line("#{log_folder}/docker1.log", "#{log_folder}/docker1-filtered.log")
			convert_file(["#{log_folder}/docker1.log", "#{log_folder}/docker2.log"], "#{log_folder}/docker-production.log")
		end
	end # namespace logs

end # namespace libra2
