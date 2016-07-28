module PublicHelper

	def file_date(date)
		return "Unknown" if date.nil?
		return date.strftime("%B %d, %Y")
	end

	def file_date_created(date)
		return "Unknown" if date.nil?
		date = date.join() if date.kind_of?(Array)
		return file_date(date) if date.kind_of?(DateTime)
		begin
			return file_date(DateTime.strptime(date, "%Y:%m:%d"))
		rescue
			begin
				return file_date(DateTime.strptime(date, "%m/%d/%Y"))
			rescue
				begin
					return file_date(DateTime.strptime(date, "%Y/%m/%d"))
				rescue
					return date
				end
			end
		end
	end

	def public_doi_link(work)
		return "Persistent link will appear here after submission." if work.is_draft?
		doi = work.permanent_url
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
			display = links.length > 1 ? raw("&bull; #{link}") : link
			a.push(content_tag(:a, display, { href: link, target: "_blank" }))
		}
		return raw(a.join(""))
	end

	def display_keywords(work)
		return "" if work.nil?
		return work.keyword.join(", ")
	end

	def display_title(work)
		return "Not Found" if work.nil?
		return work[:title][0]
	end

	def display_author(work)
		return "" if work.nil?
		return "#{work.author_last_name}, #{work.author_first_name}, #{work.department}, #{work.author_institution}"
	end

	def display_advisors(work)
		contributors = work.contributor
		advisors = []
		contributors.each { |contributor|
			arr = contributor.split("\n")
			arr.push("") if arr.length == 4 # if the last item is empty, the split command will miss it.
			# arr should be an array of [ computing_id, first_name, last_name, department, institution ]
			if arr.length == 5
				advisors.push("#{arr[2].strip}, #{arr[1].strip}, #{arr[3].strip}, #{arr[4].strip}")
			else
				advisors.push(contributor) # this shouldn't happen, but perhaps it will if old data gets in there.
			end
		}
		return raw(advisors.join("<br>"))
	end

	def display_array(value)
		if value.kind_of?(Array)
			value = value.join(", ")
		end
		return value
	end

	def display_if_non_blank(label, value)
		return "" if value.blank?
		value = raw(value.gsub("\n", "<br>"))
		row = raw(content_tag(:span, label, { class: "document-label" }) + content_tag(:span, value, { class: "document-value"}))
		return content_tag(:div, row, { class: "document-row" })
	end
end
