class AddOrderToUde < ActiveRecord::Migration

  def change
    add_column :user_default_emails, :role_order, :integer
    add_index  :user_default_emails, :role_order
  end
end
