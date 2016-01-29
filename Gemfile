source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  # gem 'web-console', '~> 2.0'
end

        # Use this file to reference specific commits of gems.

gem 'curation_concerns', '0.5.0'
#gem 'curation_concerns', github: 'projecthydra-labs/curation_concerns', branch: 'master'
# Sha-1 from Jan 13, 2016
#gem 'curation_concerns', github: 'projecthydra-labs/curation_concerns', ref: '2a91ac53a092a0e4bd0a6a0805209daac1e04892'

gem 'sufia', github: 'projecthydra/sufia', branch: 'master'
#gem 'sufia', :path => '../'
# Sha-1 from Jan 13, 2016
#gem 'sufia', github: 'projecthydra/sufia', ref: '6cbdafeebb146f5a9911547fffe08931f0617a5a'

# Required for doing pagination inside an engine. See https://github.com/amatsuda/kaminari/pull/322
gem 'kaminari', github: 'jcoyne/kaminari', branch: 'sufia'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
end

gem 'rsolr', '~> 1.0.6'
gem 'devise'
gem 'devise-guests', '~> 0.3'
group :development, :test do
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'jettywrapper'
  gem "simplecov", require: false
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug' unless ENV['CI']
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'coveralls', require: false
  gem 'mida', '~> 0.3'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_girl'
  gem 'fakeweb'
  gem 'webrat'
  gem 'capybara'
  gem 'poltergeist'
  gem 'equivalent-xml'
  gem 'fuubar'
  gem 'vcr'
  gem 'webmock'
  gem 'rspec-activemodel-mocks'
  gem 'jasmine'
end