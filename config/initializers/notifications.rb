config = YAML.load(ERB.new(IO.read(File.join(Rails.root, 'config', 'notifications.yml'))).result)[Rails.env].with_indifferent_access
POLLING_INTERVAL = config['polling_interval'] || 30
