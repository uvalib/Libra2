class ThesisMailers < ActionMailer::Base

	def thesis_can_be_submitted( whom, name )
		@name = name
    mail( to: whom, from: MAIL_SENDER, subject: "Access to upload your approved thesis or dissertation to LIBRA" )
  end

	def thesis_submitted_author(work, advisee, adviser)
		@work = work
		@advisee = advisee
		@adviser = adviser
		mail(to: work.creator, from: MAIL_SENDER, subject: "Successful deposit of your thesis")
	end

	def thesis_submitted_adviser(work, advisee, adviser)
		@work = work
		@advisee = advisee
		@adviser = adviser
		#TODO-PER: Get the adviser to mail to.
		mail(to: work.creator, from: MAIL_SENDER, subject: "Successful deposit of your advisees thesis")
	end
end
