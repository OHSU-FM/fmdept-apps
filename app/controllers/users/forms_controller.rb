class Users::FormsController < ApplicationController
  before_filter :load_user
  before_filter :load_resource, :only=>:submit
  append_before_filter :can_submit?, :only=>:submit

  ##
  # View all of the forms that this user has created (both leave and travel)
  # GET /users/1/forms
  # GET /users/1/forms.json
  def index
    @approvals = RequestSearch.forms_for @user,
      :page=>@page,
      :per_page=>@per_page
    respond_to do |format|
      format.html # forms.html.erb
      format.json {render :json => @approvals }
    end

  end

  def delegate_forms
    @approvals = RequestSearch.delegate_forms_for @user,
      :page=>@page,
      :per_page=>@per_page
    respond_to do |format|
      format.html {render template: 'users/forms/index'}
      format.json {render :json => @approvals }
    end
  end

  # PUT /users/:user_id/approvals/:id/submit
  # PUT /users/:user_id/approvals/:id/submit.json
  def submit
    # Tell the UserMailer to send email stating a request has been created
    if @approval_state.mark_as_submitted!
      # Manage response
      flash[:notice] = "Emails for #{@name} have been sent."
      simple_redirect
    else
      # An error occurred
      flash[:error] = @approval_state.errors.messages
      simple_redirect :status=>:unprocessable_entity
    end
  end

  protected

  def load_user
    @user = User.find(params[:user_id].to_i)
  end

  def load_resource
    @approval_state = ApprovalState.find(params[:id].to_i)
    @request = @approval_state.approvable

    # The request was not found, bail
    if @request.nil?
      flash[:error] = "#{@name} not found"
      simple_redirect :status=>:bad_request
    end

    @name = I18n.t("activerecord.models.#{@request.class.name.underscore}").titleize
  end


  def can_submit?
    if cannot? :update, @request
      flash[:alert] = "You do not have permission to submit this #{@name.downcase}"
      simple_redirect :status=>:unauthorized
      return
    end

    if @approval_state.submitted?
      flash[:alert] = "#{@name} already submitted"
      simple_redirect :status=>:unauthorized
      return
    end
  end

end

