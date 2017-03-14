
# Load config file for DefaultEmails
Rails.application.config.user_default_email = YAML::load(File.open("#{Rails.root}/config/user_default_emails.yml"))
