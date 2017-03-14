require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
#Bundler.require(:default, Rails.env) if defined?(Bundler)
Bundler.require(*Rails.groups)

module FmdeptApps
  class Application < Rails::Application
    config.relative_url_root  = ENV['RAILS_RELATIVE_URL_ROOT']
    #config.action_controller.relative_url_root  = ENV['RAILS_RELATIVE_URL_ROOT']

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.active_record.raise_in_transactional_callbacks = true
    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += Dir["#{Rails.root.to_s}/lib/**/*.rb"]
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    # rails will fallback to config.i18n.default_locale translation
    config.i18n.fallbacks = true

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Create custom layout for login screen
    config.to_prepare do
        # Set layout for devise
        Devise::SessionsController.layout "login"
        # Allow people to log in without contacts
        Devise::SessionsController.skip_before_filter :require_user_contacts
    end
    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Load YML files
    #config.user_default_email = YAML::load(File.open("#{Rails.root}/config/user_default_emails.yml")).with_indifferent_access
    config.role_based_resource = YAML::load(File.open("#{Rails.root}/config/role_based_resource.yml")).with_indifferent_access
    config.site_config = YAML::load(File.open("#{Rails.root}/config/site_config.yml")).with_indifferent_access

    config.railties_order = [:main_app, :all]
    config.active_record.whitelist_attributes = true
  end
end