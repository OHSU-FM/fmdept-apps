class UsersController < ApplicationController
    before_filter :require_self_or_admin, :except=>[:ldap_search]
    before_filter :scrape_params

    PER_PAGE = 20
    PAGE = 1
  
    ##
    # GET /users/1
    # GET /users/1.json
      def show
          @user = User.includes(:user_default_emails).find(params[:id])
          #prepare_contacts
          respond_to do |format|
            format.html # index.html.erb
            format.json {render :json => @user }
          end                
      end
  
      ##
      # Search LDAP server for user information
      # Custom route
      # POST /ldap_search
      # POST /ldap_search.json
      def ldap_search
        scanner = LdapQuery::Scanner.search params[:q]
        @ude = scanner.as_ude_attributes
        @ude[:errors] = scanner.errors
        respond_to do |format|
          format.json {render :json => @ude }
        end                
      end
   
      ##
      # Update user information
      # PUT /users/1
      # PUT /users/1.json
      def update
        @user = User.find(params[:id])

        if params[:user].has_key?(:is_admin) && current_user.is_admin
            @user.is_admin = params[:user][:is_admin]
        end
        @user.assign_attributes(params[:user])
        did_save = @user.save
        
        if @user.fix_ude_approval_order_gaps?
            flash[:alert] = 'There were gaps in the approval order that have been automatically corrected'
        end


        respond_to do |format|
          if did_save 
            prepare_contacts
            flash[:notice] = 'Changes have been saved'
            format.html { render :action=>:show }
            format.json { head :ok }
          else
            prepare_contacts
            format.html { render :action=>:show }
            format.json { render :json => @user.errors, :status => :unprocessable_entity }
          end
  
        end
      end
      
    protected
    # create upto the maximum number of contacts allowed
    def prepare_contacts
        return unless defined? @user
        @user.user_default_emails.sort_by{|a| a.role_id.to_i}
    end

    # Remove empty ude's if they are missing email and id
    def scrape_params
        return unless params[:user] && params[:user][:user_default_emails_attributes]
        params[:user][:user_default_emails_attributes].each { |idx,attrs|
            elem = params[:user][:user_default_emails_attributes]
            elem.delete(idx) unless attrs[:email].to_s.size > 0 || attrs[:id].to_s.size > 0 
        }
    end

    protected
    def require_self_or_admin
        if not ( current_user.is_admin or current_user.id == params[:id].to_i)
            flash[:alert] = "Access Denied"
            redirect_to current_user
            return
        end
    end

end
