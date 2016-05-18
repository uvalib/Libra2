module PublicHelper

	def file_date(date)
		return date.strftime("%B %d, %Y")
	end

	def file_date_created(date)
		return "Unknown" if date.nil?
		date = date.join() if date.kind_of?(Array)
		begin
			return file_date(DateTime.strptime(date, "%Y:%m:%d"))
		rescue
			return date
		end
	end

	def public_doi_link(work)
		return "Persistent link will appear here after submission." if work.draft == "true"
		doi = "http://dx.doi.org/#{work.identifier.gsub("doi:", "")}"
		return link_to(doi, doi)
	end

	def display_rights(rights)
		return "" if rights.blank?
		rights = rights.join(" ") if rights.kind_of?(Array)
		arr = rights.split("http")
		return rights if arr.length != 2
		return content_tag("a", arr[0], { href: "http" + arr[1], target: "_blank" })
	end

	def display_related_links(links)
		a = []
		links.each { |link|
			a.push(content_tag(:a, link, { href: link, target: "_blank" }))
		}
		return raw(a.join(", "))
	end

	def display_keywords(work)
		return work.tag.join(", ")
	end

	def display_author(work)
		return work.creator
	end

	def embargo_notice(work)
		visibility = work.visibility
		return "" if visibility == "open"
		# TODO-PER: when the embargo works, then finish wiring this up.
		#embargo_period = work.embargo_period
		#embargo_release_date = work.embargo_release_date
		restricted_area = "to UVa"
		release_date = Time.now + 1.year
		return "This item is restricted #{restricted_area} until #{file_date(release_date)}."
	end
end
