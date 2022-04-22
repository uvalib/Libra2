source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
gem 'mysql2'
# Use Puma as the app server
gem 'puma'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'kaminari', '< 1.0'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test, :rake do
  gem 'byebug', platform: :mri
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'rb-readline'
  gem 'solr_wrapper', '>= 0.3'
  gem 'fcrepo_wrapper'
  gem 'rspec-rails'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
#  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
#  gem 'spring'
#  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Sufia Related
gem 'sufia', '~> 7.4.1'
gem 'curation_concerns', '~> 1.7.6', github: 'uvalib/curation_concerns', branch: '1.7.6'
gem 'blacklight_advanced_search', '~> 6.3.1'
#gem 'blacklight-gallery', '0.8.0'
#gem 'hydra-head', '10.5.0'
#gem 'hydra-works', '0.16.0'
#gem 'hydra-pcdm', '0.10.0'
#gem 'hydra-derivatives', '3.3.2'
#gem 'rdf', '~> 2.2'
gem 'simple_form', '3.5.0'
gem 'devise'
gem 'devise-guests'

# sidekiq worker support
gem 'sidekiq'
gem 'sidekiq-failures'

gem 'rsolr', '~> 1.1.2'

gem 'rest-client'
gem 'net-scp'

# email interceptor
gem 'exception_notification'

# used for exporting/ingesting Libra content
gem 'hash_at_path'
gem 'oga'

gem 'meta-tags'
gem 'sitemap_generator'

gem 'prometheus-client'

# not yet...
#group :production do
#   gem 'clamav'
#end

gem 'active-fedora', '~> 11.5.2', github: 'uvalib/active_fedora', branch: '11-5-stable'

# service auth
gem 'jwt'
