# config/initializers/email.rb

config = YAML.load(ERB.new(IO.read(File.join(Rails.root, 'config', 'email.yml'))).result)[Rails.env].with_indifferent_access

MTA_HOST = config['email_address'] || 'none'
MTA_DOMAIN = config['email_domain'] || 'none'
MAIL_SENDER = config['email_sender'] || 'libra@virginia.edu'

settings = {
	address: MTA_HOST,
	domain: MTA_DOMAIN
}
settings[:port] = config['email_port'] if config['email_port'].present?
settings[:user_name] = config['email_user_name'] if config['email_user_name'].present?
settings[:password] = config['email_password'] if config['email_password'].present?
settings[:authentication] = config['email_authentication'] if config['email_authentication'].present?
settings[:return_path] = config['email_return_path'] if config['email_return_path'].present?
settings[:enable_starttls_auto] = config['email_enable_starttls_auto'] if config['email_enable_starttls_auto'].present?

ActionMailer::Base.smtp_settings = settings

ActionMailer::Base.default_url_options[:host] = ActionMailer::Base.smtp_settings[:return_path]

if "#{config['deliver_email']}" != 'true'
	ActionMailer::Base.register_interceptor(StagingMailInterceptor)
	emails = config['mail_intercept_recipients'] || ""
	MAIL_INTERCEPT_RECIPIENTS = emails.split(/[^\w\.@+-]+/)
end
