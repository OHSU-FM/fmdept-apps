class CreateUserDefaultEmails < ActiveRecord::Migration
  def self.up
    create_table :user_default_emails do |t|
      t.integer :user_id    # user id FK for this record
      t.string :cn          # common name (from LDAP) of recipient
      t.string :email       # email address of recipient
      t.string :displayname # Name of recipient
      t.integer :role_id, :default=>1    # Role of recipient
      t.timestamps
    end
  end

  def self.down
    drop_table :user_default_emails
  end
end
