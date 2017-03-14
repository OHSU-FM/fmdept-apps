class CreateUserFiles < ActiveRecord::Migration
  def self.up
    create_table :user_files do |t|
      t.string   :uploaded_file_file_name
      t.string   :uploaded_file_content_type
      t.integer  :uploaded_file_file_size
      t.datetime :uploaded_file_updated_at     
      t.integer  :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :user_files
  end
end
