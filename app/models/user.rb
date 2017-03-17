class User < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  scope :deleted, -> { unscoped.where('deleted_at IS NOT NULL') }
  # Setup accessible (or non protected) attributes for your model
  attr_accessible :remember_me,
    :timezone,
    :user_default_emails,
    :user_default_emails_attributes,
    :is_ldap,
    :password,
    :password_confirmation,
    :email,
    :login,
    :name,
    :user_delegations,
    :user_delegations_attributes,
    :view_admin,
    :empid,
    :emp_class,
    :emp_home

  has_many :user_default_emails,
      -> { order([:approval_order,:role_id]) }, :dependent=>:delete_all

  has_many :travel_requests
  has_many :leave_requests

  # HABTM
  has_many :user_delegations, :dependent=>:delete_all

  # People that we have delegated authority to
  has_many :delegates, :through=>:user_delegations, :dependent=>:delete_all, :class_name=>'User'

  # People that have delegated authority to us
  has_and_belongs_to_many(:delegators,
    :join_table => "user_delegations",
    :foreign_key => "delegate_user_id",
    :association_foreign_key => "user_id", :class_name=>'User')

  has_many :reviewers,
    ->{ where(['user_default_emails.role_id IN (?)', UserDefaultEmail::REVIEWER_ROLES]).order('user_default_emails.approval_order ASC') },
    :class_name=>'UserDefaultEmail'

  has_many :others_notified,
    -> {
        where(['user_default_emails.role_id NOT IN (?)', UserDefaultEmail::REVIEWER_ROLES]).
        order('user_default_emails.approval_order ASC')
    },
    :class_name=>'UserDefaultEmail'

  has_many :request_applicants_ude,
    class_name: 'UserDefaultEmail', primary_key: :email, foreign_key: :email

  has_many :request_applicants, through: :request_applicants_ude, source: :user
  has_many :editable_request_applicants,
    -> {
        where(['user_default_emails.role_id IN (?)', UserDefaultEmail::REVIEWER_ROLES]).
        order('user_default_emails.approval_order ASC')
    }, through: :request_applicants_ude, source: :user

  accepts_nested_attributes_for :user_default_emails, :allow_destroy=>true
  accepts_nested_attributes_for :user_delegations, :allow_destroy=>true

  # Validate against db, then ldap, remember users, track login info, automatic timeouts
  devise :database_authenticatable, :ldap_authenticatable, :rememberable, :trackable, :timeoutable

  # Run validations
  validates_presence_of :login
  validates_presence_of :email
  validates_presence_of :name
  validate :validate_timezone
  validates :email, :uniqueness => true
  before_validation :ldap_verify_and_update

  rails_admin do
    group 'User Information' do
        field :name
        field :empid
        field :emp_class
        field :emp_home
        field :email
        field :login
        field :sn
        field :is_admin
        field :is_ldap
        field :password
        field :password_confirmation
        field :timezone
    end

    group 'Login History' do
        active false
        field :sign_in_count
        field :current_sign_in_at
        field :last_sign_in_at
        field :current_sign_in_ip
        field :last_sign_in_ip
        field :remember_created_at
    end

    group 'Notifications Config' do
        active false
        field :user_default_emails, :has_many_association
        field :reviewers
        field :others_notified
        field :user_delegations
    end

    group 'Forms' do
        active false
        field :leave_requests
        field :travel_requests
    end

    include_all_fields
    list do
      scopes [nil, :deleted]
    end
  end

  # Enumerator for timezone attribute
  def timezone_enum
    TZInfo::Country.get('US').zones.map{|tz|tz.name}
  end

  def is_admin?
    self.is_admin
  end

  def is_ldap?
    self.is_ldap
  end

  def is_reviewer?
    return UserDefaultEmail.where(
        [
            'email = ? AND role_id IN (?)',
            self.email, UserDefaultEmail::REVIEWER_ROLES
        ]).count > 0
  end

  def prevent_email_and_name_changes
    if self.login_was != self.login
        errors.add(:base,'You are not allowed to change your user name')
    end

    if self.email_was != self.email
        errors.add(:base,'You are not allowed to change your email address')
    end

  end

  def has_reviewer?
    user = User.find(self.id)
    user.user_default_emails.each do |ude|
        return true if ude.role_id.to_i >= 2
    end
    return false
  end

  # Scan UDE's for gaps in approval order
  def fix_ude_approval_order_gaps?
    return false if self.reviewers.size == 0
    fixes_made = false

    last_o = 0
    self.reviewers.sort_by{|ude|ude.approval_order}.each do |ude|
        if ude.approval_order - last_o > 1
            ude.approval_order = last_o + 1
            ude.save
            fixes_made = true
        end
        last_o = ude.approval_order
    end
    max_o = last_o
    last_o = 0
    self.others_notified.sort_by{|ude|ude.approval_order}.each do |ude|
        if ude.approval_order > max_o
            ude.approval_order = max_o
            ude.save
            fixes_made = true
        end
    end
    return fixes_made
  end

  ##
  # Count the number of pending approvals for this user
  def approvals_count
    return 0 if self.id.nil?
    return RequestSearch.approvals_for(self, show: 'pending', per_page: 1000).count
  end

  # Get the display name
  # Get the email address
  def ldap_verify_and_update
    return unless self.is_ldap?

    scanner = LdapQuery::Scanner.search self.login, :only=>:ldap

    if scanner.errors.size > 0
        errors.add(:login, 'Login is invalid or cannot be found in OHSU\'s servers')
        return
    end

    # Update our information from ldap
    self.assign_attributes scanner.as_user_attributes

  end

  # Make sure the user has entered a valid timezone
  def validate_timezone
    self.timezone = 'America/Los_Angeles' if self.timezone.nil?
    if not TZInfo::Timezone.get(self.timezone)
        errors.add(:timezone,'invalid timezone')
    end
  end

  ##
  # Collection of users that we should have full control over
  def controllable_users
    @controllable_users ||= ([self] + delegators + delegators.map{|uu|uu.delegators}.flatten).uniq
  end

  ##
  # Collection of users that we should be allowed to view all of their stuff
  def viewable_users
    @viewable_users ||= (controllable_users + request_applicants + controllable_users.map{|uu|uu.request_applicants}).flatten.uniq
  end

  ##
  # Collection of users that we should be allowed to view all of their stuff
  def approvable_users
    @approvable_users ||= (controllable_users + editable_request_applicants + controllable_users.map{|uu|uu.editable_request_applicants}).flatten.uniq
  end


end
