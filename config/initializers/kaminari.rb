#Conflict between will_paginate and kaminari

# DOES WORK
# http://tech-brains.blogspot.com/2012/11/kaminari-willpaginate-incompatibility.html
if defined?(WillPaginate)
  module WillPaginate
    module ActiveRecord
      module RelationMethods
        def per(value = nil) per_page(value) end
        def total_count() count end
      end
    end
    module CollectionMethods
      alias_method :num_pages, :total_pages
    end
  end
end



# DID NOT WORK:
# https://github.com/sferik/rails_admin/wiki/Troubleshoot
# will_paginate is known to cause problem when used with kaminari, 
# to which rails_admin has dependency. To work around this issue, 
# create config/initializers/kaminari.rb with following content:
#Kaminari.configure do |config|
#  config.page_method_name = :per_page_kaminari
#end
