class StagingMailInterceptor
	def self.delivering_email(message)
		message.subject = "INTERCEPTED: [#{message.to}] #{message.subject}"
		message.to = MAIL_INTERCEPT_RECIPIENTS
	end
end