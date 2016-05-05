class ThesisMailers < ActionMailer::Base

  add_template_helper( UrlHelper )

	def thesis_can_be_submitted( whom, name )
		@name = name
    mail( to: whom, from: MAIL_SENDER, subject: "Access to upload your approved thesis or dissertation to LIBRA" )
  end

	def thesis_submitted(work)
		@work = work
		#TODO-PER: Get the adviser to mail to.
		mail(to: work.creator, from: MAIL_SENDER, subject: "Thesis successfully submitted")
	end
end
