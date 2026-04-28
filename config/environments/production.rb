Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.server_timing = true

  # Active Storage - S3
  config.active_storage.service = :amazon

  # Force SSL
  config.force_ssl = true

  # Logging
  config.log_level = :info
  config.log_tags = [:request_id]
  config.logger = ActiveSupport::TaggedLogging.logger($stdout)

  # Caching
  config.action_controller.perform_caching = true
  config.cache_store = :memory_store
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Assets
  config.assets.compile = false

  # Mailer
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false

  # Locale
  config.i18n.fallbacks = true

  # Deprecations
  config.active_support.report_deprecations = false

  # Schema
  config.active_record.dump_schema_after_migration = false
end
