module PublicHelper

	def file_date(date)
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
		return "Persistent link will appear here after submission." if work.draft == "true"
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
			a.push(content_tag(:a, link, { href: link, target: "_blank" }))
		}
		return raw(a.join(", "))
	end

	def display_keywords(work)
		return work.keyword.join(", ")
	end

	def display_author(work)
		return "#{work.author_last_name}, #{work.author_first_name}"
	end

	def display_advisors(work)
		first_name = work.contributor_first_name
		last_name = work.contributor_last_name
		department = work.contributor_department
		institution = work.contributor_institution
		advisors = []
		# these should all be the same length, but we're making sure anyway.
		if first_name.blank? || last_name.blank? || department.blank? || institution.blank?
			len = 0
		else
			len = 1000000

			len = first_name.length if first_name.length < len
			len = last_name.length if last_name.length < len
			len = department.length if department.length < len
			len = institution.length if institution.length < len
		end
		len.times { |i|
			advisors.push("#{last_name[i]}, #{first_name[i]}, #{department[i]}, #{institution[i]}")
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
		row = raw(content_tag(:span, label, { class: "document-label" }) + content_tag(:span, value, { class: "document-value"}))
		return content_tag(:div, row, { class: "document-row" })
	end
end
