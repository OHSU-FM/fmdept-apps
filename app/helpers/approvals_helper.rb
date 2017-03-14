module ApprovalsHelper
    STATES = {
        0=>'',   # unsubmitted
        10=>'info',         # submitted
        20=>'info',         # unopened
        30=>'info',         # in review
        40=>'info',         # missing info
        50=>'danger',       # rejected
        51=>'danger',       # expired
        60=>'info',         # approved 
        61=>'success',      # approved by final reviewer
        999=>'danger'       # error
    }
  def hf_row_status(approval_state)
    STATES[approval_state.status]
  end

  def filter_description filter_name
    case filter_name
      when 'past'
       'These are the requests that you have accepted/rejected.'
      when 'active'
       'These are the requests that you have approved that are still awaiting final approval.'
      when 'upcoming'
       'These are the requests that have been submitted but do not yet require your approval.'
      when 'pending'
       'These are the requests that are waiting for your approval.'
      when 'unsubmitted'
        'These are the requests that have not been submitted.'
      else
        'Selecting from  all approvals'
    end
  end

    FILTER_OPTS = {
        None: 'none',
        Past: 'past',
        Upcoming: 'upcoming',
        Pending: 'pending',
        Unsubmitted: 'unsubmitted'
    }

    SORT_BY_OPTS = {
        'Created at' => 'created_at',
        'Updated at' => 'updated_at'}

    SORT_ORDER_OPTS = {
        Ascending: 'asc',
        Descending: 'desc'}
    
    def hf_filter_options
        options_for_select(FILTER_OPTS, hf_filter)
    end

    def hf_sort_by_options
        options_for_select(SORT_BY_OPTS, hf_sort_by)
    end 

    def hf_sort_order_options
        options_for_select(SORT_ORDER_OPTS, hf_sort_order)
    end

    def hf_sort_by
        val = params[:sort_by].to_s 
        SORT_BY_OPTS.values.include?(val) ? val : 'created_at'
    end
    
    def hf_sort_order
        val = params[:sort_order].to_s
        SORT_ORDER_OPTS.values.include?(val) ? val : 'desc'
    end

    def hf_filter
        val = params[:filter].to_s
        title = FILTER_OPTS.values.include?(val) ? val : 'none'
        title == 'none' ? 'all' : title
    end

    def hf_forms_title
        return 'Delegate forms' if action_name == 'delegate_forms'
        return 'My Forms' if (current_user.id == @user.id) 
        return "Forms for #{@user.name}" if action_name == 'index'
    end

end
