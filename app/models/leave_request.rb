class LeaveRequest < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  # allow can_xxx?(user) based auth checks ( a role your own cancan )
  include RoleBasedResource

  # Handle links to other resources
  belongs_to :user
  has_one :leave_request_extra, :dependent=>:destroy
  has_one :travel_request

  accepts_nested_attributes_for :leave_request_extra, :allow_destroy=>true

  validates :hours_vacation,
      :hours_sick,
      :hours_other,
      :hours_training,
      :hours_comp,
      :hours_cme,
      :inclusion => {:in => 0..400, :message => "can only be between 0 and 400."},
      :if => Proc.new { |obj| obj.leave_request_extra.nil? || obj.leave_request_extra.hours_administrative.to_f == 0 }

  validate :validate_hours_presence
  validates :start_date, :end_date,:user_id, :presence=>true
  validate :validate_dates

  def related_name
    'Travel Request'
  end

  def related_record
    self.travel_request
  end

  def build_related
    build_travel_request if travel_request.nil?
    travel_request.leave_request_id = self.id
    travel_request.dest_depart_date = start_date
    travel_request.ret_depart_date  = end_date
    travel_request.dest_depart_hour = start_hour
    travel_request.ret_depart_hour  = end_hour
    travel_request.dest_depart_min  = start_min
    travel_request.ret_depart_min   = end_min
    travel_request.dest_desc        = desc
    travel_request.form_user        = form_user
    travel_request.form_email       = form_email
    travel_request.user_id          = user_id
  end

  #Validate Hours:  at leaste one hours column must contain a value
  def validate_hours_presence
    if  (self.hours_vacation == 0 && self.hours_sick==0 && self.hours_other==0 &&
        self.hours_training==0 && self.hours_comp==0 && self.hours_cme==0 ) then
        # Highlight these fields with css, but hide the message
        errors.add(:hours_vacation,'')
        errors.add(:hours_sick,'')
        errors.add(:hours_other,'')
        errors.add(:hours_training,'')
        errors.add(:hours_comp,'')
        errors.add(:hours_cme,'')
        # Show the message
        errors.add(:base,'Leave hours: cannot all be blank')

    end
  end

  # Validate order of dates
  def validate_dates
    if self.start_date && self.end_date && self.start_date > self.end_date then
        errors.add(:end_date,'') # Highlight field only (no message)
        # Show this message
        errors.add(:start_date,'Beginning of leave cannot be later than end date')
    end
  end

  # Virtual attribute: returns string stating form type
  def form_type
    if self.has_extra
        return 'Faculty'
    else
        return 'Staff'
    end
  end

  # Virtual attribute: need travel
  def is_traveling
    return (not self.travel_request.nil? or self.need_travel)
  end

  def will_change? params
    self.assign_attributes(params[self.class.name.underscore.to_sym])
    self.changed?
  end

  # Auto process only these params from POST
  attr_accessible :leave_request_extra_attributes,
    :start_date,
    :start_hour,
    :start_min,
    :end_date,
    :end_hour,
    :end_min,
    :desc,
    :hours_vacation,
    :hours_sick,
    :hours_cme,
    :hours_other,
    :hours_other_desc,
    :hours_training,
    :hours_training_desc,
    :hours_comp,
    :hours_comp_desc,
    :need_travel,
    :approval_state_attributes,
    :request_change
end
