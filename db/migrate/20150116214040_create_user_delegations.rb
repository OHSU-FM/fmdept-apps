class CreateUserDelegations < ActiveRecord::Migration
  def change
    create_table :user_delegations do |t|
      t.references :user, index: true, :null=>false
      t.integer :delegate_user_id, :index=>true, :null=>false
      t.timestamps
    end
  end
end
