###################
# 2015-6-12
- added can_cancel_request to ability model
- pseudo code for automatic email for role_based_resource
- added act_as_paranoid for both leave and travel request
###################

####################
# 2015-06-05
####################
- Added acts_as_paranoid to disable users rather than delete them

####################
# 2015-05-05
####################
- Add ability for find delegates
- Delegate leave/travel request to assistants for the reviewers
- Look at the Approval_State.approvals_for 
- Fix the user account page to add/remove delegate
- Update the emailer to find the address of delegate

####################
# 2014-06-12    
####################
X Exception notifier bug: 05/20/2014
   - activemodel (3.2.18) lib/active_model/attribute_methods.rb:407:in 'method_missing'
   - activerecord (3.2.18) lib/active_record/attribute_methods.rb:149:in 'method_missing'
   - app/controllers/leave_requests_controller.rb:195:in 'destroy'

X Add arbitrary authorization process
    - Testing routine:
    -- create/update/delete/submit a leave/travel request
    -- multi step approvals (1,2,3,4) from approvals index and from form#show
    -- test prevention of approval loops
    -- test for aborted forms (added or removed a reviewer while forms were waiting for approval)

X Authorization updates
    X Add arbitrary authorization process
    - Normalize User Default Emails Model
    -- Add ability to disable user account?
    - Authorization remaining details
    X Add nested form to user/show for authorizations approval_order
    X Add nested approvals form for request/show
    X Add list of reviewers and progress to request/show
    - specialized sql to find approval states
      that are abandoned.
      - Like when Marked as in-review, but there is no reviewer at that level


X Add PaperTrail
    X So we can view system activity
    X Delete records with impunity

X Limit approvals for reviewer to ones that they have reviewed

X Integrate Form listings so that travel requests and Leave requests are listed together

X   Laurie Approved a request that should have gone to Kam first

X   Verian Wedeking: Bug Report
    I just changed 3 requests from Lauren Oujiri to ‘in review’ 
    but on the last leave request is it reverts to ‘submitted’ 
    if I click ‘view request’ for another request and then come
    back to the ‘form approvals’ screen.  Not sure if that’s
    a very clear explanation, but let me know if you want to
    take a look at what I’m experiencing from my workstation. 

X MyForms pulls leave requests for wrong person

X Distinguish between all approvals and pending approvals

####################
# 2013-07-05
####################

- Added role_based_resource to Rails.application.config
-- Used as system for CC user notifications
-- Removed bug where Laurie would be CCed twice, now only CCed after Connie accepts

X Sender image not appearing on approvals page

X Ensure that Laurie is not CC`ed unless it is time for her to act

####################
# 2013-05-09
####################

- Restrict view for Final_Reviewer so that they only see what has been approved by the reviewer
-- Done, but what about people with only a final-reviewer and no reviewer?

- Disable editing/deletion of old (accepted and past) forms

- Fixed wording for mailer subject heading
- [Done] Unable to create new leave requests
- [Done] Set numeric field minimum to zero
- [Done] Form Actions:
    - Wont save activity because we are not on the same form element
    - Actions need to be nested inside the form

####################
# 2012-06-12    
####################
TODO Items:

    - CC all Notifiers/Reviewers/Final Reviewers instead of sending out individual emails

    - Forms and Approvals pages:
        - Pagination
        - Search
        - Sort
        - Filter

    - Timestamps show in views are not taking daylight savings into account

    - BCC admin unless admin is the owner of the request

    - Create Roles system and add Travel Agent Role

    - Add unobtrusive JS callbacks to display wait page for sending emails
        X Leave and travel request submission
        - Approvals page
        - Forms page

# Bugfixes:

- Upgraded to rails 3.2.9 (from 3.0.0)
    - undefined method 'debug_rjs=' for ActionView::Base:Class
    - According to: https://github.com/rails/prototype-rails/issues/1 we should comment out a line
    in config/environments/development.rb
    -#config.action_view.debug_rjs = true

    - replace RAILS_ROOT with Rails.root
