# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160518044448) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "approval_states", force: :cascade do |t|
    t.integer  "user_id",                                     null: false
    t.integer  "approval_order",              default: 0
    t.integer  "status",                      default: 0
    t.boolean  "form_locked",                 default: false
    t.boolean  "mail_sent",                   default: false
    t.integer  "approvable_id",                               null: false
    t.string   "approvable_type", limit: 255,                 null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "resubmitted",                 default: 0
  end

  add_index "approval_states", ["approvable_type", "approvable_id"], name: "index_approval_states_on_approvable_type_and_approvable_id", unique: true, using: :btree

  create_table "leave_request_emails", force: :cascade do |t|
    t.integer  "leave_request_id"
    t.string   "cn",               limit: 255
    t.string   "email",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leave_request_extras", force: :cascade do |t|
    t.integer  "leave_request_id"
    t.integer  "work_days"
    t.decimal  "work_hours",                            precision: 5, scale: 2, default: 0.0
    t.boolean  "basket_coverage"
    t.string   "covering",                  limit: 255
    t.decimal  "hours_professional",                    precision: 5, scale: 2, default: 0.0
    t.text     "hours_professional_desc"
    t.string   "hours_professional_role",   limit: 255
    t.decimal  "hours_administrative",                  precision: 5, scale: 2, default: 0.0
    t.text     "hours_administrative_desc"
    t.string   "hours_administrative_role", limit: 255
    t.boolean  "funding_no_cost"
    t.text     "funding_no_cost_desc"
    t.decimal  "funding_approx_cost"
    t.boolean  "funding_split"
    t.text     "funding_split_desc"
    t.string   "funding_grant",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leave_requests", force: :cascade do |t|
    t.string   "form_user",           limit: 255
    t.string   "form_email",          limit: 255
    t.date     "start_date"
    t.string   "start_hour",          limit: 255
    t.string   "start_min",           limit: 255
    t.date     "end_date"
    t.string   "end_hour",            limit: 255
    t.string   "end_min",             limit: 255
    t.text     "desc"
    t.decimal  "hours_vacation",                  precision: 5, scale: 2, default: 0.0
    t.decimal  "hours_sick",                      precision: 5, scale: 2, default: 0.0
    t.decimal  "hours_other",                     precision: 5, scale: 2, default: 0.0
    t.text     "hours_other_desc"
    t.decimal  "hours_training",                  precision: 5, scale: 2, default: 0.0
    t.text     "hours_training_desc"
    t.decimal  "hours_comp",                      precision: 5, scale: 2, default: 0.0
    t.text     "hours_comp_desc"
    t.boolean  "has_extra"
    t.boolean  "need_travel",                                             default: false
    t.integer  "status",                                                  default: 0
    t.integer  "user_id"
    t.boolean  "mail_sent",                                               default: false
    t.boolean  "mail_final_sent",                                         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.decimal  "hours_cme",                       precision: 5, scale: 2, default: 0.0
    t.text     "request_change"
  end

  add_index "leave_requests", ["deleted_at"], name: "index_leave_requests_on_deleted_at", using: :btree

  create_table "travel_files", force: :cascade do |t|
    t.integer "travel_request_id"
    t.integer "user_file_id"
  end

  create_table "travel_request_emails", force: :cascade do |t|
    t.integer  "travel_request_id"
    t.string   "cn",                limit: 255
    t.string   "email",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "travel_requests", force: :cascade do |t|
    t.string   "form_user",                 limit: 255
    t.string   "form_email",                limit: 255
    t.text     "dest_desc"
    t.boolean  "air_use",                               default: false
    t.string   "air_desc",                  limit: 255
    t.text     "ffid"
    t.date     "dest_depart_date"
    t.string   "dest_depart_hour",          limit: 255
    t.string   "dest_depart_min",           limit: 255
    t.string   "dest_arrive_hour",          limit: 255
    t.string   "dest_arrive_min",           limit: 255
    t.text     "preferred_airline"
    t.text     "menu_notes"
    t.integer  "additional_travelers"
    t.date     "ret_depart_date"
    t.string   "ret_depart_hour",           limit: 255
    t.string   "ret_depart_min",            limit: 255
    t.string   "ret_arrive_hour",           limit: 255
    t.string   "ret_arrive_min",            limit: 255
    t.text     "other_notes"
    t.boolean  "car_rental",                            default: false
    t.date     "car_arrive"
    t.string   "car_arrive_hour",           limit: 255
    t.string   "car_arrive_min",            limit: 255
    t.date     "car_depart"
    t.string   "car_depart_hour",           limit: 255
    t.string   "car_depart_min",            limit: 255
    t.text     "car_rental_co"
    t.boolean  "lodging_use",                           default: false
    t.text     "lodging_card_type"
    t.text     "lodging_card_desc"
    t.text     "lodging_name"
    t.string   "lodging_phone",             limit: 255
    t.date     "lodging_arrive_date"
    t.date     "lodging_depart_date"
    t.text     "lodging_additional_people"
    t.text     "lodging_other_notes"
    t.boolean  "conf_prepayment"
    t.text     "conf_desc"
    t.boolean  "expense_card_use",                      default: false
    t.string   "expense_card_type",         limit: 255
    t.string   "expense_card_desc",         limit: 255
    t.integer  "status",                                default: 0
    t.integer  "user_id"
    t.integer  "leave_request_id"
    t.boolean  "mail_sent",                             default: false
    t.boolean  "mail_final_sent",                       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.text     "request_change"
  end

  add_index "travel_requests", ["deleted_at"], name: "index_travel_requests_on_deleted_at", using: :btree

  create_table "user_default_emails", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "cn",             limit: 255
    t.string   "email",          limit: 255
    t.string   "displayname",    limit: 255
    t.integer  "role_id",                    default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "approval_order",             default: 0
  end

  add_index "user_default_emails", ["approval_order"], name: "index_user_default_emails_on_role_order", using: :btree

  create_table "user_delegations", force: :cascade do |t|
    t.integer  "user_id",          null: false
    t.integer  "delegate_user_id", null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "user_delegations", ["user_id", "delegate_user_id"], name: "index_user_delegations_on_user_id_and_delegate_user_id", unique: true, using: :btree

  create_table "user_files", force: :cascade do |t|
    t.string   "uploaded_file_file_name",    limit: 255
    t.string   "uploaded_file_content_type", limit: 255
    t.integer  "uploaded_file_file_size"
    t.datetime "uploaded_file_updated_at"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",               limit: 255, default: "",                    null: false
    t.string   "encrypted_password",  limit: 128, default: "",                    null: false
    t.string   "login",               limit: 255,                                 null: false
    t.string   "name",                limit: 255,                                 null: false
    t.string   "remember_token",      limit: 255
    t.boolean  "is_admin",                        default: false
    t.string   "timezone",            limit: 255, default: "America/Los_Angeles"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",  limit: 255
    t.string   "last_sign_in_ip",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sn",                  limit: 255
    t.boolean  "is_ldap",                         default: true
    t.boolean  "view_admin",                      default: false
    t.datetime "deleted_at"
  end

  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 255, null: false
    t.integer  "item_id",                    null: false
    t.string   "event",          limit: 255, null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
