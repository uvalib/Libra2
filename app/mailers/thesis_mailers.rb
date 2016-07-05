class ThesisMailers < ActionMailer::Base

  add_template_helper( UrlHelper )

  def is_under_embargo(work)
	  return false if work.embargo_state == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
	  return work.embargo_end_date > Time.now()
  end

  def visibility_string( work )
	  if is_under_embargo(work)
		  return "public access on #{work.embargo_end_date.strftime("%B %-d, %Y")}"
	  else
		  return "public access immediately"
	  end
  end

	def optional_thesis_can_be_submitted( whom, name )
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
		subject = "Successful deposit of your thesis#{ " or dissertation" if @is_sis_thesis}"
		mail(to: work.creator, from: MAIL_SENDER, subject: subject)
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
