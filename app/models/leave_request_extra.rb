class LeaveRequestExtra < ActiveRecord::Base
  has_paper_trail

    belongs_to :leave_request

    #validates :work_hours, :presence=>true

    attr_accessible :work_days,
        :work_hours,
        :basket_coverage,
        :covering,
        :hours_professional,
        :hours_professional_desc,
        :hours_professional_role,
        :hours_administrative,
        :hours_administrative_desc,
        :hours_administrative_role,
        :funding_no_cost,
        :funding_no_cost_desc,
        :funding_approx_cost,
        :funding_split,
        :funding_split_desc,
        :funding_grant
         
end
