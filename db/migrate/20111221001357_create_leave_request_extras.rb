class CreateLeaveRequestExtras < ActiveRecord::Migration
  def self.up
    create_table :leave_request_extras do |t|
    	## TABLE: leave_request_extras 
        t.integer :leave_request_id
 
    	# Leave Extended				
    	t.integer :work_days			# Total work days gone -->Will be gone 5 days and
    	t.decimal :work_hours,
    		  :precision => 5,
    		  :scale => 2,
    		  :default => 0			# Hours gone from work -->4 hours from work
    	t.boolean :basket_coverage		# I need basket coverage
    	t.string  :covering			# If work_days > 5 days who will cover for you?
    	t.decimal :hours_professional,
    		  :precision => 5,
    		  :scale => 2, 
    		  :default => 0			# Hours used for proffessional purposes
    	t.text :hours_professional_desc		# Describe use of professional hours
    	t.string  :hours_professional_role	# Role you will be assuming during event
    	t.decimal :hours_administrative,
    		  :precision => 5,
    		  :scale => 2,
    		  :default => 0			# Hours used for training purposes
    	t.text    :hours_administrative_desc	# Describe use of administrative hours
    	t.string  :hours_administrative_role	# Role at event
    	t.integer :leave_request_id		# FK for matching basic request
    	# Funding Data 
    	t.boolean :funding_no_cost		# There will be no cost to the department
    	t.text :funding_no_cost_desc		# Who is funding? (since there is no cost)
    	t.decimal :funding_approx_cost		# Approximate cost to the Department
    	t.boolean :funding_split		# We will split the cost to the department
    	t.text :funding_split_desc		# Explain how the cost will be split
    	t.string :funding_grant			# Funding can be charged to this grant
    	
        t.timestamps
    end
  end

  def self.down
    drop_table :leave_request_extras
  end
end
