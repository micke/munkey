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

ActiveRecord::Schema.define(version: 2018_06_03_152700) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

  create_table "channels", id: :bigint, default: nil, force: :cascade do |t|
    t.bigint "server_id"
    t.string "topic"
    t.boolean "gb_alerts", default: false
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.string "name"
    t.integer "position"
  end

  create_table "regions", force: :cascade do |t|
    t.citext "name"
    t.bigint "discord_id"
    t.bigint "server_id"
  end

# Could not dump table "searches" because of following StandardError
#   Unknown type 'tsquery' for column 'query'

  create_table "servers", id: :bigint, default: nil, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "users", id: :bigint, default: nil, force: :cascade do |t|
    t.string "name"
    t.boolean "blocked", default: false
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
  end

  add_foreign_key "searches", "users"
end
