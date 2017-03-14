class Users::ApprovalsController < ApplicationController
    before_filter :load_user
    append_before_filter :load_resource, :only=>[:update]
    append_before_filter :can_review?, :only=>[:update]
    append_before_filter :can_submit?, :only=>:submit
    append_before_filter :search_setup, :only=>[:index, :search, :calendar]
    include ApprovalsHelper
    PER_PAGE = 20
    PAGE = 1

    ##
    # View any form approvals that have been assigned to this user
    # GET /users/:user_id/approvals
    # GET /users/:user_id/approvals.json
    def index
      @approvals = RequestSearch.search_approvals_for @user,
          :q=>@q,
          :show=>@filter_name,
          :sort_by=> hf_sort_by,
          :sort_order=> hf_sort_order,
          :page=>@page,
          :per_page=>@per_page
      respond_to do |format|
          format.html # approvals
          format.json {render :json => @approvals }
      end
    end

    # GET /users/:user_id/approvals
    def search
      @approvals = RequestSearch.search_approvals_for @user,
          :q=>@q,
          :sort_by=> hf_sort_by,
          :sort_order=> hf_sort_order,
          :show=>@filter_name,
          :page=>@page,
          :per_page=>@per_page
      respond_to do |format|
          format.html {render action: :index}
          format.json {render :json => @approvals }
      end
    end

    def calendar
      @approvals = RequestSearch.search_approvals_for @user,
          :q=>@q,
          :show=>@filter_name,
          :page=>@page,
          :per_page=>@per_page
      respond_to do |format|
          format.html {render layout: false}
      end
    end

    # PUT /users/:user_id/approvals/:id
    # PUT /users/:user_id/approvals/:id.json
    def update
        @status = params[:approval_state][:status].to_i
        if @approval_state.status == @status
            flash[:notice] = 'Value of status has not changed'
            simple_redirect
            return
        end

        if @approval_state.reviewer_mark_status_as! @status, @user.email
            # Manage response
            flash[:notice] = "Emails for #{@name} have been sent."
            simple_redirect
        else
            # An error occurred
            flash[:error] = "There was an error updating approval status."
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

    def can_review?
        # Check permissions to see if this user is allowed to review this document
        unless can? :update, @approval_state
            flash[:alert] = "You do not have permission to review this #{@name.downcase}"
            simple_redirect :status=>:unauthorized
            return
        end

        # Users are not allowed to review requests that have not been submitted
        if @approval_state.submitted? == false
            flash[:alert] = "Unable to review form, it has not been submitted for review."
            simple_redirect :status=>:bad_request
            return
        end
    end

    def can_submit?
        if cannot? :update, @request then
            flash[:alert] = "-You do not have permission to submit this #{@name.downcase}"
            simple_redirect :status=>:unauthorized
            return
        end

        if @approval_state.submitted?
            flash.now[:alert] = "#{@name} already submitted"
            simple_redirect :status=>:unauthorized
            return
        end
    end

    def search_setup
      @filter_name = params[:filter].to_s || 'all'
      @search_filter = @filter_name
      @q = params[:q].to_s
      @page = (params[:page] || self.class::PAGE).to_i
      @per_page = (params[:per_page] || self.class::PER_PAGE).to_i
      @page = self.class::PAGE if @page < 1
      @per_page = self.class::PER_PAGE if @per_page < 1
    end

end
