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

ActiveRecord::Schema.define(version: 20150614195816) do

  create_table "assets", force: :cascade do |t|
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "choices", force: :cascade do |t|
    t.integer  "node_id"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "to_node_id"
  end

  add_index "choices", ["node_id"], name: "index_choices_on_node_id"
  add_index "choices", ["to_node_id"], name: "index_choices_on_to_node_id"

  create_table "courses", force: :cascade do |t|
    t.string   "title"
    t.string   "access_code"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "active",        default: true
    t.integer  "university_id"
  end

  add_index "courses", ["access_code"], name: "index_courses_on_access_code", unique: true
  add_index "courses", ["university_id", "title"], name: "index_courses_on_university_id_and_title", unique: true

  create_table "decisions", force: :cascade do |t|
    t.integer  "showing_session_id"
    t.integer  "from_node_id"
    t.integer  "to_node_id"
    t.integer  "result"
    t.string   "justification"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "decisions", ["from_node_id"], name: "index_decisions_on_from_node_id"
  add_index "decisions", ["showing_session_id"], name: "index_decisions_on_showing_session_id"
  add_index "decisions", ["to_node_id"], name: "index_decisions_on_to_node_id"

  create_table "enrollments", force: :cascade do |t|
    t.integer  "course_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "enrollments", ["course_id"], name: "index_enrollments_on_course_id"
  add_index "enrollments", ["user_id"], name: "index_enrollments_on_user_id"

  create_table "nodes", force: :cascade do |t|
    t.string   "title",                  default: ""
    t.text     "body"
    t.boolean  "is_start",               default: false
    t.boolean  "is_goal",                default: false
    t.boolean  "is_failure",             default: false
    t.boolean  "requires_justification", default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "scenario_id"
    t.integer  "asset_id"
    t.integer  "label"
  end

  add_index "nodes", ["asset_id"], name: "index_nodes_on_asset_id"
  add_index "nodes", ["scenario_id"], name: "index_nodes_on_scenario_id"

  create_table "scenarios", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "root_node_id"
    t.boolean  "archived"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "university_id"
    t.boolean  "locked"
  end

  add_index "scenarios", ["university_id", "name"], name: "index_scenarios_on_university_id_and_name", unique: true

  create_table "showing_sessions", force: :cascade do |t|
    t.integer  "showing_id"
    t.integer  "attempts_remaining"
    t.integer  "node_id"
    t.integer  "user_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "status",             default: 0
  end

  add_index "showing_sessions", ["node_id"], name: "index_showing_sessions_on_node_id"
  add_index "showing_sessions", ["showing_id"], name: "index_showing_sessions_on_showing_id"
  add_index "showing_sessions", ["user_id"], name: "index_showing_sessions_on_user_id"

  create_table "showings", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "scenario_id",                  null: false
    t.integer  "course_id",                    null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "is_graded"
    t.integer  "max_attempts"
    t.string   "display_name"
    t.boolean  "hidden",       default: false
  end

  add_index "showings", ["course_id"], name: "index_showings_on_course_id"
  add_index "showings", ["scenario_id"], name: "index_showings_on_scenario_id"

  create_table "universities", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "universities", ["name"], name: "index_universities_on_name", unique: true

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.integer  "role",                   default: 0
    t.integer  "university_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["username"], name: "index_users_on_username", unique: true

end
