class CreateTravelRequests < ActiveRecord::Migration
  def self.up
    create_table :travel_requests do |t|
    ########## Travel Requests ###########
    ## TABLE: travel_requests
    # Form User information
         t.string :form_user                # Who is this form filled out for?
         t.string :form_email               # Email addess of user
    #Airline
        t.text    :dest_desc                # Where will you be traveling to?
        t.boolean :air_use, :default=>false # Will you require Airline Reservations?
        t.string  :air_desc                 # description of where we are flying to
        t.text    :ffid                     # Frequent Flyer ID
        t.date    :dest_depart_date         # Date / Time you want to depart at dest

        t.string    :dest_depart_hour     # Time you want to depart airport
        t.string    :dest_depart_min     # Time you want to depart airport

        t.string    :dest_arrive_hour     # Time you want to arrive at dest
        t.string    :dest_arrive_min     # Time you want to arrive at dest

        t.text    :preferred_airline    # Preffered Airline
        t.text    :menu_notes           # Special notes about the menu?
        t.integer :additional_travelers # Number of additional travelers 
        t.date    :ret_depart_date      # Date you want to return

        t.string    :ret_depart_hour      # Time you want to depart  
        t.string    :ret_depart_min       # Time you want to depart  

        t.string    :ret_arrive_hour      # Time you want to arrive home
        t.string    :ret_arrive_min       # Time you want to arrive home

        t.text    :other_notes          # Any special notes to pass along
    #Car rental
        t.boolean :car_rental, :default=>false   # Do you want to rent a car
        t.date    :car_arrive           # First Day you want the car
        t.string    :car_arrive_hour      # Time you want the car
        t.string    :car_arrive_min       # Time you want the car

        t.date    :car_depart           # Last day you want the car
        t.string    :car_depart_hour      # Time you plan to return the car
        t.string    :car_depart_min       # Time you plan to return the car

        t.text    :car_rental_co        # Description of car rental company
    #Lodging Info
        t.boolean :lodging_use, :default=>false  # Do you need lodging accomidations?
        t.text    :lodging_card_type       # Account type
        t.text    :lodging_card_desc       # Account description to hold reservation
        t.text    :lodging_name            # Name of lodge
        t.string  :lodging_phone         # Phone number of lodge
        t.date    :lodging_arrive_date   # Date of arrival
        t.date    :lodging_depart_date   # Date of departure
        t.text    :lodging_additional_people # Additional persons staying here
        t.text    :lodging_other_notes   # Special needs and considerations
    #Conference Registration
        t.boolean :conf_prepayment      # Do you need prepayment for conference registration?
        t.text    :conf_desc            # Any other notes regarding the conference
    #Expense Information
        t.boolean :expense_card_use, :default=>false     # Will travel expenses be charged to a credit card?
        t.string  :expense_card_type    # Dropdown list (MC,VISA, etc...)
      t.string    :expense_card_desc    # Card #/desc of card
    #Status
      #t.string  :reviewed_by           # Who is processing the request
      t.integer :status, :default=>0    # Status of new request
    #Forgeign Keys
      t.integer :user_id                # userID of person filling out the form
      t.integer :leave_request_id       # leave_request_id that this was generated from
      t.boolean :mail_sent, :default=>false
      t.boolean :mail_final_sent, :default=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :travel_requests
  end
end
