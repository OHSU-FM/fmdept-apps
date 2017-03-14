class CreateTravelFiles < ActiveRecord::Migration
  def self.up
    create_table :travel_files do |t|
      t.integer :travel_request_id
      t.integer :user_file_id
    end
  end

  def self.down
    drop_table :travel_files
  end
end
