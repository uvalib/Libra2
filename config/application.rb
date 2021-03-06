require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Libra2
  class Application < Rails::Application

    #
    # enable the background job queue behavior
    config.active_job.queue_adapter = :sidekiq

    #
    # specify the name of the IP whitelist file
    config.ip_whitelist = "#{Rails.root}/data/ipwhitelist.txt"

    #
    # We introduce several namespaces in order to partition rails components clearly and stay out of the base app namespace
    # which will be subject to changes from the sufia folks.
    #
    shared_namespace = 'uva'
    app_namespace = 'libraetd'

    config.generators do |g|
      g.test_framework :rspec, :spec => true
    end


    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
     config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    #puts "==> #{paths.to_json}"
    # Look in the global namespace for stuff - this lets us override without cluttering up the root/app tree.
    # this namespace is used for global look & feel; anything that can be shared between Virgo and Libra
    paths[ 'lib/assets' ] << "lib/#{shared_namespace}/assets"

    # Look in the app namespace for stuff - this lets us override without cluttering up the root/app tree.
    paths[ 'app/controllers' ] << "lib/#{app_namespace}/app/controllers"
    paths[ 'app/views' ] << "lib/#{app_namespace}/app/views"
    paths[ 'app/models' ] << "lib/#{app_namespace}/app/models"
    paths[ 'app/helpers' ] << "lib/#{app_namespace}/app/helpers"
    paths[ 'lib/assets' ] << "lib/#{app_namespace}/app/assets"
    paths[ 'lib/tasks' ] << "lib/#{app_namespace}/tasks"
    paths[ 'config' ] << "lib/#{app_namespace}/config"

    config.autoload_paths += %W(
      #{Rails.root}/lib/#{app_namespace}/app/controllers/concerns
      #{Rails.root}/lib/#{app_namespace}/app/models/concerns
    )

    require "#{config.root}/lib/#{app_namespace}/app/helpers/url_helper"
    include UrlHelper
    Rails.application.routes.default_url_options[:host] = public_site_url

  end
end
