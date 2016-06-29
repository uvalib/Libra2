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
    mail( to: whom, from: MAIL_SENDER, subject: "Access to upload your approved thesis to LIBRA" )
	end

	def sis_thesis_can_be_submitted( whom, name )
		@name = name
    mail( to: whom, from: MAIL_SENDER, subject: "Access to upload your approved thesis or dissertation to LIBRA" )
	end

	def thesis_submitted_author( work, author )
		@work = work
		@advisee = author
		@availability = visibility_string(work)
		@doi_link = work.permanent_url
		@is_sis_thesis = work.is_sis_thesis?
		mail(to: work.creator, from: MAIL_SENDER, subject: "Successful deposit of your thesis")
	end

	def thesis_submitted_registrar( work, author, registrar_name, registrar_email )
		@work = work
		@advisee = author
		@advisor = registrar_name
		@availability = visibility_string(work)
		@doi_link = work.permanent_url
		mail(to: registrar_email, from: MAIL_SENDER, subject: "Successful deposit of your student's thesis")
	end

end
