require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Wyntaste
  class Application < Rails::Application
    config.load_defaults 8.1

    config.autoload_lib(ignore: %w[assets tasks])

    # Generator configuration
    config.generators do |g|
      g.orm :active_record, primary_key_type: :bigint
      g.test_framework :minitest
    end
  end
end
