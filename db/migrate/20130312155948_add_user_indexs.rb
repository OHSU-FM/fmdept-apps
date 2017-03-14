class AddUserIndexs < ActiveRecord::Migration
  def up    
    add_index :users, :email,                :unique => true
    add_index :users, :login,                :unique => true
  end

  def down
  end
end
