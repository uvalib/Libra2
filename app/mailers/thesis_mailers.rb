class ThesisMailers < ActionMailer::Base

	def thesis_submitted(work)
		@work = work
		#TODO-PER: Get the adviser to mail to.
		mail(to: work.creator, from: EXCEPTION_SENDER, subject: "Thesis Submitted")
	end
end
