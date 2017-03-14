
namespace :db do
    desc "Load default contacts for users"
    task :analyze => :environment do
        puts ''
        puts 'Running database analysis task...'
        puts "\tThis task will scan the database for errors and log them to a file"
        load_user_default_emails
    end
end 
  
  
# See if this user has default email contacts information to enter
def load_user_default_emails
    template_data = YAML::load(File.open("#{Rails.root}/config/user_default_emails.yml"))
    user_data = nil
    user_data = template_data['users'][self.email] if template_data['users'].has_key?(self.email)

    if not user_data.nil?
        user_data.each do |f|
            next if f['email']== self.email
            if not(self.has_finalizer? and f['role_id'].to_i == 3)
              ude = self.user_default_emails.build(:email=>f['email'],:role_id=>f['role_id'])
              ude.save!
            end
        end
        
    end   

end

