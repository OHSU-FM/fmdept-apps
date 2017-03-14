FmdeptApps::Application.routes.draw do

    mount RailsAdmin::Engine => 'admin', :as => 'rails_admin'

    devise_for :users

    resources :user_files

    # TODO: Trim unused routes
    resources :users, :except=>[:index, :new, :create] do

      resources :forms, :controller=>'users/forms', :only=>:index do
          member do 
              put 'submit'
              post 'submit'
          end
      end
      match 'delegate_forms' =>'users/forms#delegate_forms', :via=> :get, :as=>:delegate_forms

      resources :approvals, :controller=>'users/approvals', :only=>[:index, :update] do
        collection do
          get 'search/:search_filter', :action => 'search', :as => 'search' 
          get 'calendar/:search_filter', :action => 'calendar', :as => 'calendar'
        end
      end
      match 'approvals/:search_filter', controller: 'users/approvals', action: :index, via: :get, as: :approvals_filter 
    end

    # TODO: Trim unused routes
    resources :travel_requests, :except=>:index

    # TODO: Trim unused routes
    resources :leave_requests, :except=>:index

    # You can have the root of your site routed with "root"
    # just remember to delete public/index.html.
    resources :home, :only => [:index]
    root :to => "home#index"

    match 'ldap_search' => 'users#ldap_search', :via => :get, :as => :ldap_search

end
