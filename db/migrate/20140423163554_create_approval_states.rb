class CreateApprovalStates < ActiveRecord::Migration
  def up
    
    rename_column :user_default_emails, :role_order, :approval_order

    create_table :approval_states do |t|
        t.references :user, :index=>true, :null=>false
        t.integer :approval_order, :index=>true, :default=>0
        t.integer :status, :default=>0
        t.boolean :form_locked, :default=>false
        t.boolean :mail_sent, :default=>false
        t.integer :approvable_id, :index=>true, :null=>false
        t.string :approvable_type, :index=>true, :null=>false
        t.timestamps
    end

    add_index :approval_states, [:approvable_type, :approvable_id], :unique => true

    old_codes = {
          0  =>  0,     # 'Unsubmitted',                    # mail_sent = False
          1  =>  10,    # 'Submitted',                      # mail_sent = True
          10 =>  30,    # 'In Review',                      # viewed by reviewer
          11 =>  40,    # 'Missing Information',            # Marked by reviewer
          120=>  50,    # 'Rejected by reviewer',           # By reviewer
          13 =>  60,    # 'Accepted by reviewer',           # approved by reviewer
          20 =>  30,    # 'In Final Review',                # Viewed by reviewer
          21 =>  40,    # 'Missing Information',            # Marked by final reviewer
          22 =>  50,    # 'Rejected by final reviewer',     # By final reviewer
          23 =>  61,    # 'Accepted by final reviewer', 
          999=>  999}   # 'Error'}

    ActiveRecord::Base.transaction do
        ApprovalState.destroy_all

        # We are going to manually set the timestamps
        ApprovalState.record_timestamps = false

        User.all.each do |user|
            # Gather all records to update
            requests = user.leave_requests
            requests += user.travel_requests
            # Process all records 
            requests.each do |request|
                approval_state = request.build_approval_state       # Create status
                approval_state.user_id = user.id                    # Set user
                approval_state.mail_sent = request.mail_sent        # Was an email sent?
                approval_state.status = old_codes[request.status]   # Recode status
                approval_state.created_at = request.created_at
                approval_state.updated_at = request.updated_at

                if [22,23,999,120].include? request.status
                    approval_state.form_locked = true
                end

                # Check for reviewer
                reviewer = nil
                if [13,20,21,22,23,999].include? request.status
                    reviewer = user.finalizer
                    # This would have been the second round of approval
                    approval_state.approval_order = 2
                elsif [1,10,11,120]
                    reviewer = user.reviewers.first
                    # This would have been the first round of approval
                    approval_state.approval_order = 1
                end

                if reviewer
                    PaperTrail.whodunnit = User.find_by_email(reviewer.email).id
                end
                
                # Save
                approval_state.save!
            end
        end
    end

  end

    def down
        rename_column :user_default_emails, :approval_order, :role_order
        drop_table :approval_states
    end


end
