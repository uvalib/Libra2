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
		release_date = embargo_release_date(work)
		raise "Embargo date missing: release_date = #{release_date}, today = #{@today}" if release_date.nil? || @today.nil?
		return release_date > @today
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
		uva_ips = uva_ip_blocks
		#puts "==> Remote IP: #{request.remote_ip}"
		#puts "==> Forwarded IP: #{request.env["HTTP_X_FORWARDED_FOR"]}"
    in_uva_ips = uva_ips.any?{ |block| block.include?( request.remote_ip ) }
    #puts "==> At UVa: #{in_uva_ips}"
		return in_uva_ips
	end

	def uva_ip_blocks
		uva_ip_ranges_list = [ ]
		File.open( Rails.application.config.ip_whitelist, 'r' ).each_line { |line|
			line.strip!
			uva_ip_ranges_list.push line
		}

		return uva_ip_ranges_list.map { |subnet| IPAddr.new subnet }
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
