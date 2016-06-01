class ThesisMailers < ActionMailer::Base

  add_template_helper( UrlHelper )

  def visibility_string( work )
	  visibility = work.visibility
	  if visibility == 'open'
		  return "public access immediately"
	  end
	  embargo_release_date = work.embargo_release_date
	  return "public access  on #{embargo_release_date.strftime("%B %-d, %Y")}"
  end

	def thesis_can_be_submitted( whom, name )
		@name = name
    mail( to: whom, from: MAIL_SENDER, subject: "Access to upload your approved thesis or dissertation to LIBRA" )
	end

  def doi_link(work)
	  "http://dx.doi.org/#{work.identifier.gsub("doi:", "")}"
  end

	def thesis_submitted_author( work, author )
		@work = work
		@advisee = author
		@availability = visibility_string(work)
		@doi_link = doi_link(work)
		mail(to: work.creator, from: MAIL_SENDER, subject: "Successful deposit of your thesis")
	end

end
