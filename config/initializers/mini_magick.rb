require 'mini_magick'

MiniMagick.configure do |config|
  config.shell_api = "posix-spawn"
  config.timeout = 300
  config.validate_on_create = false
end
