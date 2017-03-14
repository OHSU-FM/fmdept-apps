class TravelRequestsController < ApplicationController
  before_filter :require_user_contacts, :except=>[:destroy, :show, :index]
  before_filter :load_resources, :except=>[:index,:create,:new]

  # GET /travel_requests
  # GET /travel_requests.json
  def index
    @travel_requests = TravelRequest.where user_id: current_user.id

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @travel_requests }
    end
  end

  # GET /travel_requests/1
  # GET /travel_requests/1.json
  def show
    @user = @travel_request.user
    if not @travel_request.can_view?(current_user)
        flash[:alert] = "You do not have permission to view this request"
        redirect_to :back
        return
    end

    # Is this the first time a reviewer has looked at the request?
    if @travel_request.can_review?(current_user) and ['unopened', 'submitted'].include? @travel_request.approval_state.status_str then
        # Notify user that their request is being reviewed
        @travel_request.approval_state.status_str = 'in review'
        @travel_request.approval_state.save!
    end

    @travel_request.travel_files.build.build_user_file

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @travel_request }
    end
  end

  # GET /travel_requests/new
  # GET /travel_requests/new.json
  def new
    @back_path = user_forms_path(current_user)
    @travel_request = TravelRequest.new
    @travel_request.travel_files.build.build_user_file
    @leave_request = @travel_request.build_leave_request 
    # People can fill out travel request forms for others, 
    # but the default is to fill it out for yourself
    @travel_request.form_user = current_user.name
    @travel_request.form_email = current_user.email  

    #attempt_to_get_associated

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @travel_request }
    end
  end

  # GET /travel_requests/1/edit
  def edit
    @travel_request = TravelRequest.includes(:leave_request).find(params[:id])
    @travel_request.travel_files.build.build_user_file

    if not @travel_request.can_edit?(current_user)
        flash[:alert] = "You do not have permission to edit this request"
        redirect_to :back
        return
    end

    @travel_request.travel_files.build.build_user_file
    
    respond_to do |format|
      format.html # edit.html.erb
      format.json { render :json => @travel_request }
    end

  end

  # POST /travel_requests
  # POST /travel_requests.json
  def create
    @travel_request = TravelRequest.new(params[:travel_request])
    @travel_request.user_id = current_user.id

    respond_to do |format|
      if @travel_request.save
        flash[:notice] = 'Travel request was successfully created.'
        format.html { redirect_to @travel_request }
        format.json { render :json => @travel_request, :status => :created, :location => @travel_request }
      else
        flash.now[:error] = 'Unable to create request'
        format.html { render :action => "new" }
        format.json { render :json => @travel_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /travel_requests/1
  # PUT /travel_requests/1.json
  def update

    if params[:delete]=='Delete'
        destroy
        return
    end

    if not @travel_request.can_edit?(current_user)
        flash[:alert] = "You do not have permission to edit this request"
        redirect_to :back
        return
    end
    
    @travel_request.assign_attributes(params[:travel_request])

    if params[:submit]=='Submit'
        submit
        return
    end
    
    if params[:create_related_request] || params[:create_related_request_extra]
        create_related
        return
    end
     
    
    # redirect target
    target = @travel_request

    # only allow reviewers to update the status of a request
    if params.has_key?(:travel_request) && params[:travel_request].has_key?(:status) && @travel_request.can_review?(current_user)
        @travel_request.status = params[:travel_request][:status].to_i
        if @travel_request.changed? and @travel_request.save!
        
            flash[:notice] = "Travel request status has been updated. An email has been sent to #{@travel_request.user.name} to inform them of the change."
             
            did_save = true
        end

    # Just an update occurred
    else
        flash[:notice] = 'Travel request updated'
        did_save = @travel_request.save
    end
    
    if did_save
      # Tell the UserMailer to send email stating the request status has changed
      UserMailer.travel_request_email(@travel_request).deliver 
    end

    respond_to do |format|
      if did_save 
        format.html { redirect_to target }
        format.json { render :json=>{:status=>:ok} }
      else
        flash.now[:error] = 'Unable to update form'
        format.html { render :action => "edit" }
        format.json { render :json => @travel_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /travel_requests/1
  # DELETE /travel_requests/1.json
  def destroy
    @travel_request = TravelRequest.find(params[:id])
    
    if not can? :destroy, @travel_request
        flash[:notice] = "You do not have permission to delete this request"
        redirect_to :back
        return
    end
    
    # Tell the UserMailer to send email stating a request has been created
    # UserMailer.request_canceled_email(@leave_request).deliver

    @travel_request.destroy
    flash[:notice]='Travel Request deleted, but notifications were not sent.'

    respond_to do |format|
      #format.html { redirect_to travel_requests_url }
      format.html { redirect_to @back_path }
      format.json { head :ok }
    end
  end

  def submit
    @travel_request = TravelRequest.find(params[:id])

    if not @travel_request.can_edit?(current_user) then
       flash[:notice] = 'You do not have permission to mail this travel request'
       redirect_to :back
       return
    end

    # Send an email to all default contacts
    if @travel_request.mail_sent == false
        flash[:notice] = "Travel request has been submitted."
    else
        flash[:notice] = "Travel request had been updated"
    end
    
    # Tell the UserMailer to send email stating a request has been created
    UserMailer.travel_request_email(@travel_request).deliver

    # Manage response
    respond_to do |format|
      if @travel_request.update_attributes(params[:travel_request])
        flash[:notice] = 'Travel request was successfully updated.'  
        format.html { redirect_to @travel_request }
        format.json { render :json=>{ 
            :next_page=>travel_request_path(@travel_request),
            :status=> :redirect
            }
         }
      else
        flash.now[:error] = 'Unable to update form'
        format.html { render :action => "edit" }
        format.json { render :json => @travel_request.errors, :status => :unprocessable_entity }
      end
    end

  end

  protected
  def create_related
        
    #Create related request
    @travel_request.build_related
    
    if params[:create_related_request_extra]
        @travel_request.leave_request.has_extra = true
    end

    @travel_request.leave_request.hours_vacation = 1
    did_save = @travel_request.save && @travel_request.leave_request.save
    respond_to do |format|
      if did_save
        flash[:notice] = 'Leave Request was successfully created!'
        format.html { redirect_to polymorphic_path @travel_request.leave_request, :action=>:edit }
        format.json { render :json => {:status=>:ok} }
      else
        flash[:error] = 'Unable to create leave request'
        format.html { redirect_to @travel_request }
        format.json { render :json => @travel_request.errors, :status => :unprocessable_entity }
      end
    end
    
  end

  def load_resources
    @travel_request = TravelRequest.unscoped.includes(:leave_request).find(params[:id])

    @travel_request.create_approval_state if @travel_request.approval_state.nil?
    
    # Load user (for shared show partial)
    @user = current_user

    # show reviewer forms
    @show_form_controls = @travel_request.can_review?(current_user)
    
    # Alternate back buttons depending on the user
    if @travel_request.can_review?(current_user) && current_user.id != @travel_request.user_id
        @back_path = user_approvals_path(current_user)
    else
        @back_path = user_forms_path(current_user)
    end  

  end
  
  ##
  # 
  def attempt_to_get_associated 
   
    if not @travel_request.leave_request_id.nil?
      @leave_request = LeaveRequest.find_by_id(@travel_request.leave_request_id)
    end

    if not @leave_request
      @leave_request = LeaveRequest.new() 
    end

  end

end
