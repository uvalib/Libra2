# config/initializers/email.rb

settings = {
	address: ENV['EMAIL_ADDRESS'],
	domain: ENV['EMAIL_DOMAIN'],
}
settings[:port] = ENV['EMAIL_PORT'] if ENV['EMAIL_PORT'].present?
settings[:user_name] = ENV['EMAIL_USER_NAME'] if ENV['EMAIL_USER_NAME'].present?
settings[:password] = ENV['EMAIL_PASSWORD'] if ENV['EMAIL_PASSWORD'].present?
settings[:authentication] = ENV['EMAIL_AUTHENTICATION'] if ENV['EMAIL_AUTHENTICATION'].present?
settings[:return_path] = ENV['EMAIL_RETURN_PATH'] if ENV['EMAIL_RETURN_PATH'].present?
settings[:enable_starttls_auto] = ENV['EMAIL_ENABLE_STARTTLS_AUTO'] if ENV['EMAIL_ENABLE_STARTTLS_AUTO'].present?

ActionMailer::Base.smtp_settings = settings

ActionMailer::Base.default_url_options[:host] = ActionMailer::Base.smtp_settings[:return_path]

if ENV['DELIVER_EMAIL'] != 'true'
	ActionMailer::Base.register_interceptor(StagingMailInterceptor)
	emails = ENV['MAIL_INTERCEPT_RECIPIENTS'] || ""
	MAIL_INTERCEPT_RECIPIENTS = emails.split(/[^\w\.@+-]+/)
end
