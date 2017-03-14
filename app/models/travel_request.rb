class TravelRequest < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  # allow can_xxx?(user) based auth checks ( a role your own cancan )
  include RoleBasedResource
  belongs_to :leave_request
  belongs_to :user

  has_many :travel_files, :dependent=>:destroy, :inverse_of=>:travel_request
  has_many :user_files, :through=>:travel_files, :dependent=>:destroy
  has_one :approval_state, :as=>:approvable, :dependent=>:destroy


  validates_associated :approval_state
  #validates_associated :travel_files
  #validates_associated :user_files
  validates_presence_of :dest_depart_date,
    :ret_depart_date,
    :form_email,
    :form_user,
    :user

  accepts_nested_attributes_for :approval_state, :allow_destroy=>true
  accepts_nested_attributes_for :travel_files, :allow_destroy=>true
  accepts_nested_attributes_for :user_files, :allow_destroy=>true

  validate :validate_dates

  def related_name
    'Leave Request'
  end

  def related_record
    self.leave_request
  end

  def build_related
    build_leave_request if leave_request.nil?
    leave_request.user_id     = user_id
    leave_request.start_date  = dest_depart_date
    leave_request.end_date    = ret_depart_date
    leave_request.start_hour  = dest_depart_hour
    leave_request.end_hour    = ret_depart_hour
    leave_request.start_min   = dest_depart_min
    leave_request.end_min     = ret_depart_min
    leave_request.desc        = dest_desc
    leave_request.form_user   = form_user
    leave_request.form_email  = form_email
    leave_request.need_travel = true
  end

  # TODO: Fix this, it is required by a shared view
  def form_type
    ''
  end

  # Validate order of dates
  def validate_dates
    # Validate travel dates
    if self.dest_depart_date && self.ret_depart_date then
        if self.dest_depart_date > self.ret_depart_date then
            errors.add(:ret_depart_date,'') # Highlight field only (no message)
            # Show this message
            errors.add(:dest_depart_date,'Travel: Beginning of leave cannot be later than end date')
        end
    end
    #validate lodging dates
    if self.lodging_arrive_date && self.lodging_depart_date then
        if self.lodging_arrive_date > self.lodging_depart_date then
            errors.add(:lodging_depart_date,'') # Highlight field only (no message)
            # Show this message
            errors.add(:lodging_arrive_date,'Lodging: Arrival date cannot be later than end date')
        end
    end
    #validate car rental dates
    if self.car_arrive && self.car_depart && self.car_arrive > self.car_depart then
        errors.add(:car_depart,'') # Highlight field only (no message)
        # Show this message
        errors.add(:car_arrive,'Car Rental: Arrival date cannot be later than end date')
    end

  end

  after_create :update_leave_request
  def update_leave_request
    return if self.leave_request.nil?

    self.leave_request.need_travel = true
    self.leave_request.save!
  end


  # Limit access to all attributes except for these ones
   attr_accessible :form_user,
     :form_email,
     :dest_desc,
     :air_desc,
     :air_use,
     :ffid,
     :dest_depart_date,
     :dest_depart_hour,
     :dest_depart_min,
     :dest_arrive_hour,
     :dest_arrive_min,
     :preferred_airline,
     :menu_notes,
     :additional_travelers,
     :ret_depart_date,
     :ret_depart_hour,
     :ret_depart_min,
     :ret_arrive_hour,
     :ret_arrive_min,
     :other_notes,
     :car_rental,
     :car_arrive,
     :car_arrive_hour,
     :car_arrive_min,
     :car_depart,
     :car_depart_hour,
     :car_depart_min,
     :car_rental_co,
     :lodging_use,
     :lodging_card_type,
     :lodging_card_desc,
     :lodging_name,
     :lodging_phone,
     :lodging_arrive_date,
     :lodging_depart_date,
     :lodging_additional_people,
     :lodging_other_notes,
     :conf_prepayment,
     :conf_desc,
     :expense_card_use,
     :expense_card_type,
     :expense_card_desc,
     :user_files_attributes,
     :travel_files_attributes,
     :approval_state_attributes,
     :request_change
end
