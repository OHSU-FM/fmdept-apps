class RequestSearch < ApprovalState

  rails_admin do
    list do
      field :id do
        searchable false
      end
      field :user do
        searchable [{User => :name, User => :login}]
        queryable true
      end
      field :approval_order do
        searchable false
      end
      field :status do
        searchable false
      end
      field :mail_sent do
        searchable false
      end
    end
  end

  ##
  # Get approval states for this user and 2 deep delegators
  def self.delegated_approvals_for user, ops={}
    # Create a user object if only an id is provided
    user = User.find user unless user.respond_to? :attributes
    # Build our SQL statement
    sql_strings = []
    sql_params = []
    user.controllable_users.each do |user|
      sql_string, sql_param = self.sql_generator(user, ops)
      sql_params += sql_param
      sql_strings.push sql_string
    end
    # Execute SQL and return result
    return self.paginated_results( sql_params.unshift(sql_strings.join("\nUNION ALL\n")), opts)
  end

  def self.delegator_emails_for user
    user.controllable_users.map{|u|u.email}
  end

  def self.approvals_for user, opts={}
    sql_string, sql_params = self.sql_generator(user, opts)
    sql_params.unshift(sql_string)
    return self.paginated_results(sql_params, opts)
  end

  ##
  # Find ids containing value
  def self.search_for_ids(queries)
    sub_q = queries.split(' ')[0..4]
    lr_ids = Set.new
    tr_ids = Set.new
    operator = 'or'
    sub_q.each do |qval|
      qval = qval.downcase

      # Set join operator and hit next
      if ['and', 'or', 'not'].include?(qval)
        operator = qval
        next
      end

      q = "%#{qval}%"
      if qval == 'travel'
        ids = TravelRequest.pluck(:id)
        tr_ids = array_join(operator, tr_ids, ids)
        lr_ids = Set.new if operator == 'and'
      elsif qval == 'leave'
        ids = LeaveRequest.pluck(:id)
        lr_ids = array_join(operator, lr_ids, ids)
        tr_ids = Set.new if operator == 'and'
      else
        ids = LeaveRequest.includes(:user).where(
          ["lower(users.email) LIKE ?
             OR lower(users.login) LIKE ?
             OR lower(\"desc\") LIKE ?
             OR lower(form_email) LIKE ?
             OR lower(form_user) LIKE ?", q, q, q, q, q]
        ).pluck(:id)
        lr_ids = array_join(operator, lr_ids, ids)

        ids = TravelRequest.includes(:user).where(
          ["lower(users.email) LIKE ?
             OR lower(users.login) LIKE ?
             OR lower(dest_desc) LIKE ?
             OR lower(form_email) LIKE ?
             OR lower(form_user) LIKE ? ", q, q, q, q, q]
        ).pluck(:id)
        tr_ids = array_join(operator, tr_ids, ids)
      end
      operator = 'and'
    end
    [lr_ids, tr_ids]
  end

  ##
  # Set operator actions
  def self.array_join(opp, arr1, arr2)
    if opp == 'and'
      return arr1 & arr2
    elsif opp == 'not'
      return arr1 - arr2
    end
    return arr1 | arr2
  end

  ##
  # Search for values
  def self.search_approvals_for user, opts={}
    sql_string, sql_params = self.sql_generator(user, opts)
    # search with query if there is one
    if opts[:q].present?
      lr_ids, tr_ids = search_for_ids(opts[:q])

      where_query = "AND (
            ( approvable_type='LeaveRequest' AND approvable_id IN (?) ) OR
            ( approvable_type='TravelRequest' AND approvable_id IN (?) )
          )
      "
      sql_string.sub!('ORDER BY', "#{where_query} ORDER BY")
      sql_params.push lr_ids
      sql_params.push tr_ids
    end
    sql_params.unshift(sql_string)
    return self.paginated_results(sql_params, opts)
  end

  # return approval states for requests that this user is supposed to approve
  def self.sql_generator user, opts={}
    # Create a user object if only an id is provided
    user = User.find user unless user.respond_to? :attributes
    if opts[:show] == 'past'
      ## Requests that we have already approved
      # only hide things that have not been submitted
      ignore_states = INCOMPLETE_STATES
      # Show all approvals
      ao_str = 'AND (
                a.approval_order > ude.approval_order OR
                (
                    a.approval_order = ude.approval_order AND
                    a.status IN (50,61)
                )
            )'
    elsif opts[:show] == 'upcoming'
      ## Requests that do not yet require our approval
      # only hide things that have not been submitted
      ignore_states = REVIEWER_IGNORE_STATES
      # Show all approvals
      ao_str = 'AND a.approval_order < ude.approval_order'

      elsif opts[:show] == 'active'
        ## Requests that have been completed but not finished
        # only hide things that have not been submitted
        ignore_states = REVIEWER_IGNORE_STATES
        # Show all approvals
        ao_str = 'AND a.approval_order > ude.approval_order'

      elsif opts[:show] == 'pending'
        ## Requests that currently require our approval
        # Default, show pending approvals
        # Hide requests that are complete
        ignore_states = REVIEWER_IGNORE_STATES
        # AND ones that are ready for our approval
        ao_str = 'AND a.approval_order = ude.approval_order'
      elsif opts[:show] == 'unsubmitted'
        ignore_states = NO_STATES
        ao_str = "AND a.status = 0"
      else
        ignore_states = NO_STATES
        ao_str = ''
      end
    sort_order = ['desc', 'asc'].include?(opts[:sort_order]) ? opts[:sort_order] : 'desc'
    sort_by = opts[:sort_by]
    if 'created_at' == sort_by || 'updated_at' == sort_by
      sort_by = "a.#{sort_by}"
    else
      sort_by = "a.created_at"
    end
    query ="
            SELECT DISTINCT a.*
            FROM approval_states a
            JOIN users u
                ON u.id = a.user_id
            JOIN user_default_emails ude
                ON ude.user_id = u.id
    #{ao_str}
            WHERE
                ude.email in (?)
                AND ude.role_id IN (?)
                AND a.status NOT IN (?)
            ORDER BY #{sort_by} #{sort_order}
            "
            emails = user.controllable_users.map{|u|u.email}
            return query, [emails, UserDefaultEmail::REVIEWER_ROLES, ignore_states]
  end

  def self.paginated_results(query, opts)
    return self.paginate_by_sql(
      query,
      :page=>opts[:page],
      :per_page=>opts[:per_page])
  end

  # Return approval states for all forms that have been created for this user
  def self.forms_for user, opts={}
    # -1 means "show everything"
    #ignore_states = (opts[:filter_all] == true) ? NO_STATES : COMPLETED_STATES
    ignore_states = NO_STATES
    page = opts[:page]
    per_page = opts[:per_page]

    # Create a user object if only an id is provided
    user = User.find user unless user.respond_to? :attributes
    return self.paginate_by_sql(["
            SELECT a.*
            FROM approval_states a
            JOIN users u
                ON a.user_id = u.id
            WHERE
                u.id = ?
                AND a.status NOT IN (?)
            ORDER BY a.updated_at DESC
                                 ", user.id, ignore_states], :page=>page, :per_page=>per_page)
  end

  # Return approval states for all forms that have been created for this user
  def self.delegate_forms_for user, opts={}
    # -1 means "show everything"
    ignore_states = NO_STATES
    page = opts[:page]
    per_page = opts[:per_page]

    # Create a user object if only an id is provided
    user = User.find user unless user.respond_to? :attributes
    return self.paginate_by_sql(["
            SELECT DISTINCT a.*
            FROM approval_states a
            JOIN users u
                ON a.user_id = u.id
            JOIN user_delegations ud
                ON ud.user_id = u.id
            WHERE
                ud.delegate_user_id = ?
                AND a.status NOT IN (?)
            ORDER BY a.updated_at DESC
                                 ", user.id, ignore_states], :page=>page, :per_page=>per_page)
  end


end
