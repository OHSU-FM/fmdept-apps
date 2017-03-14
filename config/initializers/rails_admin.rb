# RailsAdmin config file. Generated on March 14, 2014 14:46
# See github.com/sferik/rails_admin for more informations


# Until we update to rails 4 rails_admin is stuck on an old release,
# We will need to rename the paperTrail class so that histories work
class Version < PaperTrail::Version

end
require 'rails_admin_show_in_app'
showable_models = ['User','LeaveRequest', 'TravelRequest']

RailsAdmin.config do |config|
  config.actions do
    # root actions
    dashboard do
        statistics false
    end

    # Collection Actions
    index
    history_index
    export
    bulk_delete

    # Member Actions
    new
    edit
    show
    delete
    history_show do
        visible do
            bindings[:abstract_model].model.to_s != 'User'
        end
    end
    ##
    # Does not include relative url
    show_from_app do
        visible do
            showable_models.include? bindings[:abstract_model].model.to_s
        end
    end

  end

  ################  Global configuration  ################

  # Set the admin name here (optional second array element will appear in red). For example:
  config.main_app_name = ['Fmdept Apps', 'Admin']
  # or for a more dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }

  # RailsAdmin may need a way to know who the current user is]
  config.current_user_method { current_user } # auto-generated

  # If you want to track changes on your models:
  # config.audit_with :history, 'User'

  # Or with a PaperTrail: (you need to install it first)
  config.audit_with :paper_trail, 'User'
  
  config.authorize_with :cancan
  config.current_user_method &:current_user

  # Display empty fields in show views:
  config.compact_show_view = false

  # Number of default rows per-page:
  config.default_items_per_page = 50

  # Label methods for model instances:
  # config.label_methods << :description # Default is [:name, :title] 
  #config.excluded_models << "PaperTrail::Version"
  config.excluded_models << "LeaveRequestExtra"
  config.excluded_models << "TravelFile"


end
