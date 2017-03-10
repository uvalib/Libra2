rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

config = YAML.load(ERB.new(IO.read(File.join(rails_root, 'config', 'redis.yml'))).result)[rails_env]
config[:namespace] = "libra-etd-workerpool:#{rails_env}"

Sidekiq.configure_server do |s|
  s.redis = config
end

Sidekiq.configure_client do |s|
  s.redis = config
end
