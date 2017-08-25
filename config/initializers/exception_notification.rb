config = YAML.load(ERB.new(IO.read(File.join(Rails.root, 'config', 'exception.yml'))).result)[Rails.env].with_indifferent_access
EXCEPTION_PREFIX = config['exception_email_prefix'] || ""
EXCEPTION_RECIPIENTS = config['exception_recipients'] || ""
EXCEPTION_SENDER = config['exception_sender_address'] || ""

if Rails.env.production?
	Libra2::Application.config.middleware.use ExceptionNotification::Rack,
		:email => {
			:email_prefix => EXCEPTION_PREFIX,
			:sender_address => EXCEPTION_SENDER,
			:exception_recipients => EXCEPTION_RECIPIENTS.split(/[^\w\.@+-]+/)
		}
end
