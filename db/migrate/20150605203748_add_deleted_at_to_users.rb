class AddDeletedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :deleted_at, :datetime
    add_index :users, :deleted_at
    add_column :leave_requests, :deleted_at, :datetime
    add_index :leave_requests, :deleted_at
    add_column :travel_requests, :deleted_at, :datetime
    add_index :travel_requests, :deleted_at
  end
end
