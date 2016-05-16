module PublicHelper

	def file_date(date)
		return date.strftime("%m/%d/%Y")
	end

	def public_doi_link(work)
		return "Persistent link will appear here after submission." if work.draft == "true"
		return "http://dx.doi.org/#{work.identifier.gsub("doi:", "")}"
	end
end
