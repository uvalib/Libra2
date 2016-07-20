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
			tmp = "#{output[0]}.tmp"
			of = File.new(tmp, "w")
			of.close
			input.each { |file|
				strip_non_rails(file, tmp)
			}
			`export LC_ALL='C' && sort -k1 < #{tmp} > #{tmp}.tmp` #sort by time, since the blocks are sometimes written out of order.
			format_file("#{tmp}.tmp", output[0])
			`rm #{tmp}`
			`rm #{tmp}.tmp`

			of = File.new(output[1], "w")
			of.close
			input.each { |file|
				get_import_data(file, output[1])
			}
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
				"[CANCAN]",
				"/healthcheck",
				"HealthcheckController",
				"Completed 200 OK",
				'Usergroups are ["public", "registered"]',
				'Attempted to init base path `libra2/prod`, but it already exists',
				"Warning: considering '0000000000 XXXXX n' as a free entry.",
				"Looking for edit field partial"
			]
			noise.each { |item|
				return true if line.include?(item)
			}
			# The non-rails logs start with the date.
			noise2 = [
				/^\d\d\d\d\/\d\d\/\d\d \d\d:\d\d:\d\d/,
			]
			noise2.each { |item|
				return true if line.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').match(item)
			}
			return false
		end

		def get_import_data(input, output)
			of = File.new(output, "a")
			capture = false
			File.open(input, "r").each_line do |line|
				if line.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').index("Importing from: /depositauth-ws/sis/from_sis")
					capture = true
					of.puts("")
					of.puts("")
				elsif line.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').index("/healthcheck")
					capture = false
				end
				if capture
					of.puts(line)
				end
			end
			of.close
		end

		def strip_non_rails(input, output)
			of = File.new(output, "a")
			last_timestamp = ""
			File.open(input, "r").each_line do |line|
				index = line.index("]:")
				line = line[index+3,line.length] # get rid of the tacked on stuff that looks like: 2016-07-14T09:49:00-04:00 dockerprod1 docker/49a126baed37[6764]:
				if !(is_noise(line))
					# If there is no timestamp on the line, then insert one
					#D, [2016-07-17T14:35:51.693245 #90]
					if line.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').match(/^[A-Z], \[\d\d\d\d\-\d\d\-\d\dT\d\d:\d\d:\d\d\./)
						arr = line.split("]")
						last_timestamp = arr[0] + ']' # pick up the initial "D," and then the timestamp.
					else
						last_timestamp = last_timestamp.gsub(/\.\d+/) {|match|
							".#{match[1..match.length].to_i + 1}"
						}
						line = last_timestamp + line
					end
					of.puts(line)
				end
			end
			of.close
		end

		#
		# To use this:
		# get the log files from production. They are here:
		# syslog.lib.virginia.edu:./logs/dockerprod1/docker.log log/docker1.log
		# syslog.lib.virginia.edu:./logs/dockerprod2/docker.log log/docker2.log
		# And put them in the log folder.
		#
		# The resultant output files will be easier to read and split apart by the application that created them.
		#
		desc "Get rid of non-Libra2 items from log file"
		task clean_up: :environment do |t, args|
			log_folder = "#{Rails.root}/log"
			convert_file(["#{log_folder}/docker1.log", "#{log_folder}/docker2.log"],
				[ "#{log_folder}/docker-production.log", "#{log_folder}/docker-import.log"])
		end
	end # namespace logs

end # namespace libra2
