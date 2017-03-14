class ChangeApprovalOrderDefault < ActiveRecord::Migration
  def up
    change_column_default :user_default_emails, :approval_order, 0
    change_column_default :approval_states, :approval_order, 0

    ActiveRecord::Base.transaction do
        UserDefaultEmail.all.each do |ude|
            if ude.role_id.to_i < 3
                ude.approval_order = 1
            else
                ude.approval_order = 2
            end
            ude.save!
        end
        ApprovalState.all.each do |a_state|
            if a_state.approval_order.nil?
                a_state.approval_order = 1
                a_state.save!
            end
        end
    end
  end

  def down
  end
end
