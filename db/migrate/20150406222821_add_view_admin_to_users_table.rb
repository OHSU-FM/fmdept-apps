class AddViewAdminToUsersTable < ActiveRecord::Migration
  def change
    add_column :users, :view_admin, :boolean, :default=>false
  end
end
