class ApplicationController < ActionController::Base
    protect_from_forgery
    before_filter :authenticate_user!
    append_before_filter :check_for_pagination, :only=>:index
    append_before_filter :check_for_ajax_error
    append_before_filter :set_cache_buster

    PER_PAGE = 10
    PAGE = 1

    rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
        redirect_to ApplicationController.config.relative_url_root, :notice => exception.message
    end

    rescue_from CanCan::AccessDenied do |exception|
        redirect_to ApplicationController.config.relative_url_root, :notice => exception.message
    end

    # TODO: Rescue from other errors as well: 404, database has no connection etc...
    # Create custom error pages as well.

    # helper function for request controllers
    def require_user_contacts xuser=nil
      xuser = current_user if xuser.nil?
      return false if current_user.nil?
      return false if current_user.id.nil?
      return false if current_user.id != xuser.id

      if current_user.fix_ude_approval_order_gaps?
        flash[:alert] = 'There were gaps in your approval order that were automatically corrected'
      end
      if !current_user.has_reviewer?
          flash.keep[:alert] = 'Account incomplete, please add a reviewer before creating/viewing requests'
          respond_to do |format|
              format.html {redirect_to current_user}
              format.json { render :json=>opts[:json], :status=>opts[:status] }
          end
          return true
      end
      return false
    end

    # simple redirect on bad request
    def simple_redirect opts={}
        opts[:to] ||= :back
        opts[:json] ||= flash
        opts[:status] ||= :ok
        
        respond_to do |format|
            format.html {redirect_to opts[:to]}
            format.json { render :json=>opts[:json], :status=>opts[:status] }
        end 
    rescue ActionController::RedirectBackError
        respond_to do |format|
            format.html { redirect_to root_path }
            format.json { render :json=>opts[:json], :status=>opts[:status] }
        end 
    end

    # pagination boilerplate for listing records
    def check_for_pagination
      @page = params[:page] || self.class::PAGE
      @per_page = params[:per_page] || self.class::PER_PAGE
    end

    # Redirect client when an ajax call fails. Display an error
    def check_for_ajax_error 
        return unless params[:ajax_error] == 'true'
        flash[:error] = 'Request failed. A server error has occurred'
        respond_to do |format|
            # redirect to current path and strip ajax_error parameter
            format.html {redirect_to request.fullpath.sub(/(\??)(ajax_error=true)/,'')}
        end
    end

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
