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

ActiveRecord::Schema.define(version: 20180517091220) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "credentials", primary_key: "username", id: :string, force: :cascade do |t|
    t.bigserial "id", null: false
    t.string "password"
    t.string "entity"
    t.string "hostName"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "environments", force: :cascade do |t|
    t.string "name"
    t.jsonb "parameters"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "env_type"
  end

  create_table "jenkins_servers", primary_key: "url", id: :string, force: :cascade do |t|
    t.bigserial "id", null: false
    t.string "name"
    t.string "username"
    t.string "password"
    t.string "os"
    t.string "browser", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "salesforce_cons", force: :cascade do |t|
    t.string "client_id"
    t.string "client_secret"
    t.string "grant_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings", primary_key: "name", id: :string, force: :cascade do |t|
    t.bigserial "id", null: false
    t.json "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "templates", primary_key: "Job", id: :string, force: :cascade do |t|
    t.bigserial "id", null: false
    t.string "Name"
    t.json "Project"
    t.json "Suit"
    t.json "Section"
    t.json "Profile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "OS"
    t.string "Environment", array: true
    t.string "TestRailServer"
    t.boolean "scheduled"
    t.json "Browser", array: true
    t.json "jenkinsServer", array: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin"
    t.boolean "status"
  end

end
