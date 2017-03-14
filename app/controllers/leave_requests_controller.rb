class LeaveRequestsController < ApplicationController

  before_filter :require_user_contacts, :except=>[:destroy, :show, :index]
  before_filter :load_resources, :except=>[:index, :create, :new]
  before_filter :can_edit?, :only=>[:update, :submit]

  # GET /leave_requests
  # GET /leave_requests.json
  def index
    unless current_user.is_admin
        flash[:alert] = 'You do not have permission to view all of the requests'
        redirect_to current_user
        return
    end

    @leave_requests = LeaveRequest.paginate(:page=>@page,:per_page=>@per_page).order('created_at DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @leave_requests }
    end
  end

  # GET /leave_requests/1
  # GET /leave_requests/1.json
  def show
    @show_form_controls = false
    if not can? :read, @leave_request then
       flash[:alert] = 'You do not have permission to view this request'
       simple_redirect
       return
    end
    # Is this the first time a reviewer has looked at the request?
    if @leave_request.can_review?(current_user) and ['unopened', 'submitted'].include? @leave_request.approval_state.status_str then
        # Notify user that thier request is being reviewed
        @leave_request.approval_state.status_str = 'in review'
        @leave_request.approval_state.save!
    end

    respond_to do |format|
        format.html # show.html.erb
        format.json { render :json => @leave_request }
    end

  end

  # GET /leave_requests/new
  # GET /leave_requests/new.json
  def new
    @back_path = user_forms_path(current_user)
    @leave_request = LeaveRequest.new
    # Show faculty leave request
    if params[:extra]=='true' then
        @leave_request.build_leave_request_extra
        @leave_request.has_extra=true
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @leave_request }
    end

  end

  # GET /leave_requests/1/edit
  def edit
    @leave_request = LeaveRequest.find(params[:id])

    unless @leave_request.can_edit?(current_user) then
       flash[:alert] = 'You do not have permission to edit this request'
       redirect_to @back_path
       return
    end

    if @leave_request.has_extra then
        @leave_request.build_leave_request_extra
    end

  end

  # POST /leave_requests
  # POST /leave_requests.json
  def create

    # determine user_id of leave_request
    user_id = current_user.id
    if params[:leave_request].has_key?(:user_id)
        user_id = params[:leave_request][:user_id]
        params[:leave_request].delete :user_id
    end

    # Create leave_request
    @leave_request = LeaveRequest.new(params[:leave_request])
    @leave_request.form_user  = current_user.name
    @leave_request.form_email = current_user.email
    @leave_request.user_id = user_id

    respond_to do |format|
      if @leave_request.save
          flash[:notice] = 'Leave request was successfully created.'
          format.html { redirect_to @leave_request }
          format.json { render :json => {
                    :status => :redirect,
                    :next_page => leave_request_path( @leave_request )
                }
            }
      else
        flash.now[:error] = 'Unable to create request.'
        format.html { render :action => "new" }
        format.json { render :json => @leave_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /leave_requests/1
  # PUT /leave_requests/1.json
  def update
    if params[:delete]=='Delete'
        destroy
        return
    end

    if params[:submit]=='Submit'
        submit
        return
    end

    # Send Emails
    if params.has_key?(:leave_request) and params[:leave_request].has_key?(:status) and @leave_request.can_review?(current_user)
        # only allow reviewers to update the status of a request
        @leave_request.status = params[:leave_request][:status].to_i

        if @leave_request.changed? and @leave_request.save!

            flash[:notice] = "Leave request status has been updated. An email has been sent to #{@leave_request.user.name} to inform them of the change."

            # Tell the UserMailer to send email stating a request has been created
            UserMailer.leave_request_email(@leave_request).deliver

            redirect_to :back
            return
        end
    end

    if params.has_key?(:create_related_request) then
        @leave_request.build_related
    end

    respond_to do |format|
      if !@leave_request.will_change? params
        redirect_to @leave_request
        break
      end
      if @leave_request.update_attributes(params[:leave_request])
        @leave_request.approval_state.reset_to_unsubmitted
        # Tell the UserMailer to send email stating the request status has changed
        UserMailer.leave_request_email(@leave_request.approval_state).deliver

        if params.has_key?(:create_related_request)
            if @leave_request.travel_request.save
                flash[:notice] = 'Travel request was successfully created.'
                format.html { redirect_to @leave_request.travel_request}
            else
                flash[:notice] = 'Unable to create travel request'
                format.html { redirect_to @leave_request}
            end
        else
            flash[:notice] = 'Leave request was successfully updated.'
            format.html { redirect_to @leave_request}
        end
        format.json { render :json =>{:status=>:ok}}
      else
        flash.now[:error] = 'Unable to update request.'
        format.html { render  :action => "edit" }
        format.json { render :json => @leave_request.errors, :status => :unprocessable_entity }
      end
    end

  end

  # DELETE /leave_requests/1
  # DELETE /leave_requests/1.json
  def destroy

    if not can? :destroy, @leave_request
        flash[:alert] = 'You do not have permission to delete this request'
        respond_to do |format|
          format.html { redirect_to @back_path }
          format.json { render json: {message: 'Not Authorized'}, status: 401 }
        end
        return
    end
    # Tell the UserMailer to send email stating a request has been created
    #UserMailer.request_canceled_email(@leave_request).deliver_later
    @leave_request.destroy

    respond_to do |format|
      flash[:notice] = 'Leave Request deleted, but notifications were not sent'
      format.html { redirect_to @back_path }
      format.json { head :ok }
    end
  end

  def review

    # Check permissions
    unless @leave_request.can_review?(current_user)
        respond_to do |format|
            flash.now[:error] = 'Unable to review request.'
            format.html { render :action => :back }
            format.json { render :json =>{ :status => :unprocessable_entity }}
        end
        return
    end

    # only allow reviewers to update the status of a request
    unless params && params[:leave_request] && params[:leave_request][:status]
        respond_to do |format|
            flash.now[:error] = 'Nothing has changed'
            format.html { render :action => :back }
            format.json { render :json =>{ :status => :nothing_changed }}
        end
        return
    end

    @leave_request.status = params[:leave_request][:status].to_i

    if @leave_request.changed? and @leave_request.save!
        flash[:notice] = "Leave request status has been updated. An email has been sent to #{@leave_request.user.name} to inform them of the change."
        # Tell the UserMailer to send email stating a request has been created
        UserMailer.leave_request_email(@leave_request).deliver
        redirect_to :back
    end

  end

  private
  def load_resources
    @leave_request = LeaveRequest.unscoped.includes(:leave_request_extra).includes(:travel_request).find(params[:id])

    @user = current_user
    @show_form_controls = @leave_request.can_review?(current_user)

    if @leave_request.can_review?(current_user) && current_user.id != @leave_request.user_id
        @back_path = user_approvals_path(current_user)
    else
        @back_path = user_forms_path(current_user)
    end
    @leave_request.build_approval_state if @leave_request.approval_state.nil?
  end

  def can_edit?
    if cannot? :update, @leave_request then
        flash[:alert] = 'You do not have permission to edit or submit this leave request'
        simple_redirect
    end
  end

end
