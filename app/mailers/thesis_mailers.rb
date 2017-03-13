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

	def optional_thesis_can_be_submitted( to, sender_name, from )
		subject = 'Access to upload your approved thesis to LIBRA'
		logger.info "Sending email (optional available); to: #{to} (#{sender_name}), from: #{from}, subject: #{subject}"
		@name = sender_name
    mail( to: to, from: from, subject: subject )
	end

	def sis_thesis_can_be_submitted( to, sender_name, from )
		subject = 'Access to upload your approved thesis or dissertation to LIBRA'
		logger.info "Sending email (SIS available); to: #{to} (#{sender_name}), from: #{from}, subject: #{subject}"

		@name = sender_name
		mail( to: to, from: from, subject: subject )
	end

	def thesis_submitted_author( work, author, from )
		@work = work
		@advisee = author
		@availability = visibility_string(work)
		@doi_link = work.permanent_url
		@is_sis_thesis = work.is_sis_thesis?

		subject = "Successful deposit of your thesis#{ " or dissertation" if @is_sis_thesis}"
		to = work.creator
		logger.info "Sending email (success to author); to: #{to} (#{author}), from: #{from}, subject: #{subject}"

		mail( to: to, from: from, subject: subject )
	end

	def thesis_submitted_registrar( work, author, registrar_name, registrar_email, from )
		@work = work
		@advisee = author
		@advisor = registrar_name
		@availability = visibility_string(work)
		@doi_link = work.permanent_url

		subject = 'Successful deposit of your student\'s thesis'
		to = registrar_email
		logger.info "Sending email (success to registrar); to: #{to} (#{registrar_name}), from: #{from}, subject: #{subject}"

		mail( to: to, from: from, subject: subject )
	end

end
