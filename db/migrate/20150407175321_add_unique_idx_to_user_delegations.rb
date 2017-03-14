class AddUniqueIdxToUserDelegations < ActiveRecord::Migration
  def change
      add_index :user_delegations, [:user_id, :delegate_user_id], :unique=>true 
  end
end
