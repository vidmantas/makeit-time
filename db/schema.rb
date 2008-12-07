# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081207123903) do

  create_table "activities", :force => true do |t|
    t.string   "name"
    t.boolean  "is_billable"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_enterable", :default => true
  end

  add_index "activities", ["is_billable"], :name => "index_activities_on_is_billable"
  add_index "activities", ["is_enterable"], :name => "index_activities_on_is_enterable"

  create_table "employees", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "sector_id"
    t.string   "email"
    t.integer  "position_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "login",       :limit => 25
  end

  add_index "employees", ["login"], :name => "index_employees_on_login"
  add_index "employees", ["position_id"], :name => "index_employees_on_position_id"
  add_index "employees", ["sector_id"], :name => "index_employees_on_sector_id"

  create_table "employees_projects", :id => false, :force => true do |t|
    t.integer  "employee_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "employees_projects", ["employee_id", "project_id"], :name => "index_employees_projects_on_employee_id_and_project_id"

  create_table "positions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.integer  "manager_id"
    t.string   "code",       :limit => 10
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "duration"
  end

  add_index "projects", ["code"], :name => "index_projects_on_code"
  add_index "projects", ["duration"], :name => "index_projects_on_duration"
  add_index "projects", ["end_date"], :name => "index_projects_on_end_date"
  add_index "projects", ["manager_id"], :name => "index_projects_on_manager_id"
  add_index "projects", ["start_date"], :name => "index_projects_on_start_date"

  create_table "sectors", :force => true do |t|
    t.string   "code",       :limit => 10
    t.string   "name"
    t.integer  "manager_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sectors", ["code"], :name => "index_sectors_on_code"
  add_index "sectors", ["manager_id"], :name => "index_sectors_on_manager_id"

  create_table "tasks", :force => true do |t|
    t.integer  "project_id"
    t.integer  "employee_id"
    t.integer  "activity_id"
    t.date     "date"
    t.string   "description"
    t.integer  "hours_spent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tasks", ["activity_id"], :name => "index_tasks_on_activity_id"
  add_index "tasks", ["date"], :name => "index_tasks_on_date"
  add_index "tasks", ["employee_id"], :name => "index_tasks_on_employee_id"
  add_index "tasks", ["project_id"], :name => "index_tasks_on_project_id"

end
