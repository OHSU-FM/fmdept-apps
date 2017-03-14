# include extension to allow for role based resources
require "./lib/role_based_resource"

module RoleBasedResource
    roles = Rails.application.config.role_based_resource[:roles]
    @@notifier = roles['notifier']
    @@reviewer = roles['reviewer']
    @@finalizer = roles['finalizer']


    @@finished_states = [
        roles['rejected by reviewer'],       
        roles['rejected by final reviewer'], 
        roles['accepted by final reviewer'] 
    ]

end
