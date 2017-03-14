class UserDelegation < ActiveRecord::Base
  attr_accessible :delegate_user_id, :email
  attr_accessor :email

  belongs_to :user, :inverse_of=>:user_delegations
  belongs_to :delegate, :class_name=>'User', :foreign_key=>:delegate_user_id
  validates_presence_of :user_id, :user
  validates_presence_of :delegate_user_id, :delegate
  validates_uniqueness_of :delegate_user_id, :scope => [:user_id]
  before_validation :find_email

  # imports
  has_paper_trail

  rails_admin do
  	field :delegate do
  		inline_add false
        inline_edit false
  	end
  end

  def name
    delegate.nil? ? nil : delegate.name
  end

  def email
    delegate.nil? ? @email : delegate.email
  end

  def email= val
    @email = val
  end

  ##
  # Use email as a search term to set the delegate_user
  def find_email
    val = @email
    return if val.nil? 
    val = LdapQuery::Scanner.search(val).as_user_attributes[:email] 
    if val.nil?
        errors.add :base, 'Email address not found'
        return false
    end
    @email = val
    xdelegate = User.find_by_email(val.to_s)
    if xdelegate.nil?
        errors.add :base, 'Email does not have an account on this website'
        return false
    else
        self.delegate_user_id = xdelegate.id
    end

  end

end
