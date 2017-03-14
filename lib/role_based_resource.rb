# Mixin with models that belong to user to
# allow can_xxx?(user) based auth checks ( a role your own cancan )
# May need to change user_default_emails to user_roles or some such
require 'active_support/concern'

module RoleBasedResource

    extend ActiveSupport::Concern
    ROLES = {
        1=>'notifier',
        2=>'reviewer',
        3=>'finalizer',
        4=>'travel agent'
    }

    REVIEWER_ROLES = [2, 3]

    included do
        has_one :approval_state, :as=>:approvable, :dependent=>:destroy
        after_create :save_approval_state

        #before_delete :che
        '''
        # cc all users in our current approval order 
        cc_users = self.contacts.map{|ude|ude.email}
        
        # set subject header
        mail_opts = {
            :to=>user.email,
            :subject => "#{request.class.model_name.human} for #{user.name} has been canceled",
            :cc=>cc_users.uniq
        }
        
        UserMailer.send("#{approvable.class.name.underscore}_email", self, mail_opts).deliver
        '''
    end

    module ClassMethods
        ##################################
        # Class Methods
        ##################################

    end

  ##################################
  # Instance Methods
  ##################################

  def save_approval_state
    self.build_approval_state if self.approval_state.nil?
    approval_state.user_id = user_id
    self.approval_state.save!
  end

  # all associated roles can view
  def can_view?(xuser)

    return true if xuser.id == self.user_id
    return true if xuser.is_admin
    return true if self.new_record?
    return false if self.user.user_default_emails.nil?

    self.user.user_default_emails.each do |emails|
        return true if emails.email.to_s == xuser.email.to_s
    end
    return false
  end

  def can_edit?(xuser)
    return true if xuser.is_admin                        # Admins can edit
    return true if xuser.id == self.user_id
    return true if self.new_record?                     # New record
    return false if self.user.user_default_emails.nil?  # User has no reviewers or finalizers

    # Check to see if this user is in the reviewer or finalizer categories
    self.user.user_default_emails.each do |emails|       
        if emails.email.to_s == xuser.email.to_s && emails.role_id == @@finalizer
            return true 
        end
    end
    
    # This user is not in the reviewer or finalizer category
    return false
  end

  def can_delete?(xuser)
    return true if xuser.is_admin?
    return true if xuser.id == self.user.id

    self.user.user_default_emails.each do |ude|
        next if ude.email.to_s != xuser.email.to_s  
        return true if ude.role_id == @@finalizer
    end

    return false
  end

  def can_review?(xuser)
    return false if self.user.user_default_emails.nil?
    self.user.user_default_emails.each do |ude| 
        next if ude.email.to_s != xuser.email.to_s       
        return true if RoleBasedResource::REVIEWER_ROLES.include?(ude.role_id)
    end
    return false
  end

end

