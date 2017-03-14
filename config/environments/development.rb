FmdeptApps::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false
  config.assets.debug = true
  config.assets.logger = false # Dont log asset get requests

  config.eager_load = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_mailer.delivery_method = :smtp

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true

  # Load credentials and connection information for sending emails via development
  @gmail_config = YAML::load(File.open("#{Rails.root.to_s}/config/gmail.yml"))['development']
  # Convert yaml keys to :symbols
  @gmail_config = @gmail_config.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

  config.action_mailer.smtp_settings = @gmail_config

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
  
  # devise
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
end

