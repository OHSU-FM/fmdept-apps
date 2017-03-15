class AddBenFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :empid, :integer
    add_column :users, :emp_class, :string
    add_column :users, :emp_home, :string
  end
end
