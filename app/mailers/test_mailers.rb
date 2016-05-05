class TestMailers < ActionMailer::Base

	def email()
		mail(to: EXCEPTION_RECIPIENTS, from: MAIL_SENDER, subject: "Libra2 Test Email")
	end
end
