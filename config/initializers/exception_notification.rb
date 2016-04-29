EXCEPTION_PREFIX = ENV['EXCEPTION_EMAIL_PREFIX'] || ""
EXCEPTION_RECIPIENTS = ENV['EXCEPTION_RECIPIENTS'] || ""
EXCEPTION_SENDER = ENV['EXCEPTION_SENDER_ADDRESS'] || ""

if Rails.env.to_s != 'development' && Rails.env.to_s != 'test'
	Libra2::Application.config.middleware.use ExceptionNotification::Rack,
		:email => {
			:email_prefix => EXCEPTION_PREFIX,
			:sender_address => EXCEPTION_SENDER,
			:exception_recipients => EXCEPTION_RECIPIENTS.split(/[^\w\.@+-]+/)
		}
end
