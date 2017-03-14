# Responsibilities
# - Send mail
# - Determine who should receive the mail

class UserMailer < ActionMailer::Base
  # Include application helper for availability in usermailer view
  helper :application

  # Include application helper for availability here (mail controller)
  include ApplicationHelper
  include Devise::Controllers::Helpers
  helper_method :current_user

  default :from => Rails.application.config.site_config[:mailer][:return_address]  

  def request_canceled_email(request, opts={})
    approval_state = request.approval_state
    @request = request
    opts = mail_opts(@request, approval_state).merge(opts)
    opts[:cc].push Rails.application.config.site_config[:default_travel_agent][:email]
    send_email_for @request, approval_state, opts
  end

  def travel_request_email(approval_state, opts={})
    @travel_request = approval_state.approvable
    opts = mail_opts(@travel_request, approval_state).merge(opts)
    opts[:cc].push Rails.application.config.site_config[:default_travel_agent][:email]
    send_email_for @travel_request, approval_state, opts
  end

  def leave_request_email(approval_state, opts={})
    @leave_request = approval_state.approvable
    opts = mail_opts(@leave_request, approval_state).merge(opts)
    opts[:to] = [opts[:to], @leave_request.form_email] if @leave_request.form_email
    send_email_for @leave_request, approval_state, opts 
  end
  
  protected

  def send_email_for request, approval_state, opts
    @show_form_controls = false # Prevent mailer view from showing form controls (edit/etc...)
    @approval_state = approval_state
    if approval_state.state_author && approval_state.state_author.ends_with?(Rails.application.config.site_config[:mailer][:domain])
        opts[:from] = approval_state.state_author
    else
        opts[:from] = Rails.application.config.site_config[:mailer][:return_address]
    end
    send_mail_with opts
  end

  # Single function to send email
  def send_mail_with opts
    # Remove cc duplicates
    opts[:cc].uniq!
    # don't allow :to value in :cc array
    opts[:cc].delete(opts[:to])
    opts = development_filter(opts)
    # Send email
    mail(:to=>opts[:to],
         :cc=>opts[:cc],
         :attachments=>opts[:attachments],
         :subject=>opts[:subject],
         :from=>opts[:from]
    )
  end

  # Generate mail options
  def mail_opts request, approval_state
    # Get user
    user = request.user 
    mail_to = [user.email]
    # Attach any files that might be present
    #if request.respond_to?(:user_files)
    #    request.user_files.each {|f|
    #        attachments[f.uploaded_file_file_name] = {
    #            :content => File.read( f.uploaded_file_path ),
    #            :mime_type=>f.uploaded_file_content_type
    #        }
    #    }
    #end
    
    opts = {:to=>mail_to, :subject=>'', :attachments=>attachments}
    opts[:cc] ||= []
    return opts
  end

  # remove cc list and send email to site admin
  def development_filter opts
    if Rails.env == 'development'
        opts[:subject] += "DEVELOPMENT<TO: #{opts[:to]}/><CC:'#{opts[:cc].join(';')}'/><subject:'#{opts[:subject]}'/>"
        opts[:cc]=[]
        opts[:to] = [Rails.application.config.site_config[:admin][:email]]
    end
    return opts
  end

end
