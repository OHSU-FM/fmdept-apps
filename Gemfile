source 'http://rubygems.org'

gem 'rails', '~> 4.2'
gem 'protected_attributes'
gem 'jquery-rails'                      # Jquery
gem 'sass'
gem 'coffee-rails'
gem 'uglifier'
gem 'bootstrap-sass'
gem 'bootstrap-datepicker-rails'
gem 'pg'#, '~> 0.17.0'

# Use rails_admin
gem 'rails_admin'   # rails_admin
gem 'paper_trail'

#Authorization gem
#gem 'cancancan'

# Config file loader
# see ./lib/settings.rb and ./config/settings.yml for details
gem 'settingslogic'

# Easy Forms
gem 'cocoon'

# File attachments
gem "paperclip", "~> 4.1.1"

# Mailer?
gem 'mail'#, '2.5.3' # https://github.com/mikel/mail/issues/548 Ignoring version 2.5.4 because of bug

# Auth and Ldap auth
gem 'devise'
gem 'devise_ldap_authenticatable'
gem 'cancancan'

# User timezone mapping information
gem 'tzinfo', '~> 1.1'

# pagination
gem 'will_paginate', '~> 3.0'

gem "paranoia"#, "~> 1.0"

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do

    if RUBY_VERSION =~ /^1.9.3/
        # Better error messages in development
        gem 'debugger'
        gem 'pry'
        # Better error messages in development
        #gem 'better_errors', :platforms=>[:ruby_19]
    elsif RUBY_VERSION =~ /^2.2./
        gem 'pry'
        gem 'stackprof'
        gem 'ruby-prof'
        # Better error messages in development
        gem 'better_errors'#, :platforms=>[:ruby_19]
    end
    gem 'thin'
    ## Interactive debugging from the web
    gem 'binding_of_caller'#, :platforms=>[:ruby_19]
end


gem 'sass-rails'
gem 'execjs'


group :production do
    # Send emails to admin when an error occurs
    gem 'exception_notification', '~> 4.0.1'
end
