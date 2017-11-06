module EmbargoHelper

	def embargo_release_date(work)
		# If the thesis is unpublished, then we calculate the release date as if it were being published today. This appears on the proof page, so
		# it is a good bet that the next thing the user will do is publish.
		# This probably won't be called if there isn't an embargo, but just in case, we set the release date to the past.
		return Time.now() - 1.day if work.embargo_state == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
		if work.is_draft?
			return GenericWork.calculate_embargo_release_date( work.embargo_period )
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

    # TODO: roll-up identical functionality from DownloadBehavior:is_allowed_to_see_file

		#return true if work.is_draft? # Only the author can see the draft view, and the author should always be able to see files.

    if current_user.nil? == false && work.is_mine?( current_user.email )
      puts "==> work is user owned; file access is GRANTED"
      return true
    end

    # show files if there is no embargo
		if is_under_embargo(work) == false
      puts "==> work is public; file access is GRANTED"
      # it's not embargoed so we can see it
      return true
    end

    # can never see engineering embargoed files
		if is_engineering_embargo(work)
      puts "==> work is under engineering embargo; file access is DENIED"
      return false
    end

    # must be UVA embargo, so only see files on grounds.
    on_grounds = is_on_grounds()
    puts "==> work is under embargo and we are off grounds; file access is DENIED" if on_grounds == false
    puts "==> work is under embargo and we are on grounds; file access is GRANTED" if on_grounds == true
    return on_grounds

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
    puts "===> #{request.remote_ip} @ UVa is #{in_uva_ips}"
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
