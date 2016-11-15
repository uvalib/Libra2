rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

config = YAML.load(ERB.new(IO.read(File.join(rails_root, 'config', 'redis.yml'))).result)[rails_env]
Resque.redis = Redis.new( config.merge(thread_safe: true ) )

Resque.inline = false
Resque.redis.namespace = "libra2:#{rails_env}"
Resque.logger.level = Logger::INFO