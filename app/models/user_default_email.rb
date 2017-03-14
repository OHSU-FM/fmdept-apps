class UserDefaultEmail < ActiveRecord::Base
    has_paper_trail
    belongs_to :user
    belongs_to :approver, :class_name=>'User', :primary_key=>:email, :foreign_key=>:email

    MAX_CONTACTS = 10 
    attr_accessible :role_id, :email, :approval_order, :cn, :displayname, :sn
  
    before_validation :check_ldap

    # Only allow an email address to be added once per user
    validates_uniqueness_of :email, :scope => [:user_id, :approval_order]
    validates_presence_of :role_id, :user, :approval_order
 
    # TODO: Enable approval order validation once new system is implemented
    # validates_presence_of :approval_order
    validates_presence_of :email
    validate :email_veracity

    # Only allow MAX_CONTACTS number of notifications
    validate :max_contacts, :on => :create
    # Do not allow a user to add themselves to the notification list
    #validate :no_self

    # TODO: Remove #3 (used to be final reviewer)
    ROLE_CODES={
        1=>'Notify',
        2=>'Reviewer',
        3=>'Reviewer' 
    }
    REVIEWER_ROLES = [2, 3]

    ## RAILS ADMIN
    rails_admin do
        field :user
        field :role_id, :enum do
            searchable false
        end
        field :approver do
            inline_add false
            inline_edit false
        end
        field :displayname
        field :approval_order, :enum do
            searchable false
        end
    end
   
    def email_veracity 
        email =~ /\A[^@]+@[^@]+\Z/
    end

    # for rails_admin
    # Virtual attribute: mapped to displayname
    def name
        "#{self.displayname || self.email}(#{self.approval_order})"
    end
    
    # for rails_admin
    def role_id_enum
        return ROLE_CODES.invert
    end

    # for rails_admin
    def approval_order_enum
        return (1..5).to_a
    end

    def wants_notification_of? record_status
        notify_states = Rails.application.config.role_based_resource[:notify_states]
        return notify_states[self.role_name].include?(record_status)
    end

    # Get the timezone of the user that created this ude
    def timezone
        self.user.timezone
    end

    # check to see if the user has created more than the max number of contacts
    def max_contacts
        return if self.user.nil? || self.user.email.nil?
        users  = UserDefaultEmail.where user_id: self.user_id
        if users.count > MAX_CONTACTS
            errors.add(:base,'A maximum of 10 contacts are allowed per user')
        end
    end

    # Users should not be able to add themselves to the contacts list
    #def no_self
    #    return if self.user.nil? || self.user.is_admin
    #    user = User.find(self.user_id)
    #    if user.email == self.email
    #        errors.add(:email, 'Email address of user cannot be on the contacts list')
    #    end
    #end

    # Search LDAP server for user information and return a UserDefaultEmail instance object
    def check_ldap
        # Only validate when it changes
        return unless self.email_changed?
        return unless LdapQuery.queryable? self.email

        scanner = LdapQuery::Scanner.search self.email, :only=>:ldap 

        if scanner.errors.size > 0
            errors.add(:email, 'Email is invalid or cannot be found in OHSU\'s servers')
            return false
        end

        # Update our information from ldap
        self.assign_attributes scanner.as_ude_attributes
    end

    # TODO: Deprecate
    def role_name
        Rails.application.config.role_based_resource[:roles].each{|k,v|
            return k if v.to_i == self.role_id.to_i
        }
        raise 'Unknown role_id'
    end

    def role_id_str(return_all=false)

        codes = ROLE_CODES
        return codes if return_all

        if codes.include?(self.role_id)
            return codes[self.role_id]
        else
            return 'Error'
        end
        
    end

end
