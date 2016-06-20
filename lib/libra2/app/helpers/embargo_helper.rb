module EmbargoHelper

	def embargo_release_date(work)
		# If the thesis is unpublished, then we calculate the release date as if it were being published today. This appears on the proof page, so
		# it is a good bet that the next thing the user will do is publish.
		# This probably won't be called if there isn't an embargo, but just in case, we set the release date to the past.
		return Time.now() - 1.day if work.embargo_state == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
		if work.is_draft?
			return work.resolve_embargo_date()
		else
			return work.embargo_end_date
		end
	end

	def is_under_embargo(work)
		return false if work.embargo_state == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
		return embargo_release_date(work) > @today
	end

	def is_engineering_embargo(work)
		return work.embargo_state == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
	end

	def is_non_engineering_embargo(work)
		return work.embargo_state == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
	end

	def show_proof_embargo_notice(work)
		return work.is_draft? && is_under_embargo(work)
	end

	def allow_file_access(work)
		return true if work.is_draft? # Only the author can see the draft view, and the author should always be able to see files.
		return true if !is_under_embargo(work) # show files if there is no embargo
		return false if is_engineering_embargo(work) # hide files if "dark", or engineering embargo
		# The only other choice is non-engineering embargo, in which case the files are shown if on grounds.
		return is_on_grounds()
	end

	def is_on_grounds()
		if @grounds_override
			return true if @grounds_override == 'on'
			return false if @grounds_override == 'off'
		end
		return true if uva_ip_blocks.any?{ |block| block.include?(request.remote_ip) }
		return false
	end

	def uva_ip_blocks
		# TODO-PER: hardcoding the UVA IP addresses until we come up with a system:
		ips = [ # "127.0.0.0/8", the original file included localhost. Should it?
		"128.143.0.0/16",
		"137.54.0.0/16",
		"199.111.160.0/19",
		"199.111.192.0/18",
		"172.16.0.0/16",
		"172.18.32.0/22",
		"172.19.0.0/16",
		"172.23.0.0/16",
		"172.25.0.0/16",
		"172.26.0.0/16",
		"172.27.0.0/16"]
		uva_ip_ranges_list = []
		ips.each { |ip_range|
			arr = ip_range.split("/")
			ip_arr = arr[0].split(".")
			count = arr[1]
			count.to_i.times { |x|
				ip_arr[3] = ip_arr[3].to_i + x
				uva_ip_ranges_list.push(ip_arr.join("."))
			}
		}

		# The following reads the file:
		# uva_ip_ranges_list =[]
		# File.open(UVA_IP_ADDRESSES_FILE,"r").each_line { |line|
		# 	uva_ip_ranges_list.push line
		# }
		return uva_ip_ranges_list
	end

	def embargo_notice(work)
		return "" if !is_under_embargo(work)

		restricted_area = is_engineering_embargo(work) ? "abstract view only" : "UVA"
		return "This item is restricted to #{restricted_area} until #{file_date(embargo_release_date(work))}."
	end

	def create_radio(name, value, label, is_default = false)
		attr = { type: "radio", name: name, value: value}
		if params[name.to_sym] == value || (params[name.to_sym].nil? && is_default)
			attr[:checked] = 'checked'
		end
		return content_tag(:input, ' ' + label, attr)
	end
end
