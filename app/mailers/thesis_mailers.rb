class ThesisMailers < ActionMailer::Base

	def thesis_can_be_submitted( whom )
    mail( to: whom, from: MAIL_SENDER, subject: "Your thesis can now be added" )
  end

	def thesis_submitted(work)
		@work = work
		#TODO-PER: Get the adviser to mail to.
		mail(to: work.creator, from: MAIL_SENDER, subject: "Thesis successfully submitted")
	end
end
