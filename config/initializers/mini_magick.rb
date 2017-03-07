require 'mini_magick'

MiniMagick.configure do |config|
  config.shell_api = "posix-spawn"
  config.timeout = 600
  config.validate_on_create = false
  config.validate_on_write = false
  config.logger.level = Logger::DEBUG
end
