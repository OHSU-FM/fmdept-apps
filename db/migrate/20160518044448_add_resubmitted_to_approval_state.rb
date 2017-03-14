class AddResubmittedToApprovalState < ActiveRecord::Migration
  def change
    add_column :approval_states, :resubmitted, :integer, :default => 0
  end
end
