class CreateLeaveRequests < ActiveRecord::Migration
  def self.up
    create_table :leave_requests do |t|
    	########## Leave Requests #############
    	## TABLE: leave_requests
    	# Form User information
    	t.string :form_user			# Who is this form filled out for?
    	t.string :form_email		# Email addess of user
    	# Leave Basic
    	t.date :start_date			# Date leave begins
    	t.string :start_hour		# Hour leave begins
        t.string :start_min         # Min leave begins
    	t.date :end_date			# Date return to work
    	t.string :end_hour			# Time return to work
        t.string :end_min
    	t.text :desc				# Description for purpose of leave
    	t.decimal :hours_vacation,
    		  :precision => 5,
    		  :scale => 2,
    		  :default => 0			    # Hours used for vacation
    	t.decimal :hours_sick,
    		  :precision => 5,
    		  :scale => 2,
    		  :default => 0			    # Hours used for sick time
    	t.decimal :hours_other,
    		  :precision => 5,
    		  :scale => 2,
    		  :default => 0			    # Hours used for category `other`
    	t.text :hours_other_desc		# Describe use of other hours
    	t.decimal :hours_training,
    		  :precision => 5,
    		  :scale => 2,
    		  :default => 0			    # Hours used for training purposes
    	t.text :hours_training_desc		# Describe training hours
    	t.decimal :hours_comp,
    		  :precision => 5,
    		  :scale => 2,
    		  :default => 0			                # Hours used for comp purposes
    	t.text :hours_comp_desc			            # Describe use of comp hours
    	# Status
        t.boolean :has_extra                        # has extra form?
    	t.boolean :need_travel, :default=> false    # Do you need travel arranged?
    	t.integer :status, :default=>0              # Status of request
    	#t.string :reviewed_by			            # Manager that reviewed leave request
    	#User
    	t.integer :user_id			                # UserID of person filling out the form
        t.boolean :mail_sent, :default=>false
        t.boolean :mail_final_sent, :default=>false

      t.timestamps
    end
  end

  def self.down
    drop_table :leave_requests
  end
end
