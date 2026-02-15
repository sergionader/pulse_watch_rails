# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_14_231210) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "checks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error_message"
    t.jsonb "headers", default: {}
    t.uuid "monitor_id", null: false
    t.integer "response_time_ms"
    t.integer "status_code"
    t.boolean "successful", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_checks_on_created_at"
    t.index ["monitor_id", "created_at"], name: "index_checks_on_monitor_id_and_created_at"
    t.index ["monitor_id"], name: "index_checks_on_monitor_id"
  end

  create_table "incident_updates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "incident_id", null: false
    t.text "message", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["incident_id"], name: "index_incident_updates_on_incident_id"
  end

  create_table "incidents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "resolved_at"
    t.integer "severity", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["severity"], name: "index_incidents_on_severity"
    t.index ["status"], name: "index_incidents_on_status"
  end

  create_table "incidents_monitors", id: false, force: :cascade do |t|
    t.uuid "incident_id", null: false
    t.uuid "monitor_id", null: false
    t.index ["incident_id", "monitor_id"], name: "index_incidents_monitors_on_incident_id_and_monitor_id", unique: true
    t.index ["incident_id"], name: "index_incidents_monitors_on_incident_id"
    t.index ["monitor_id"], name: "index_incidents_monitors_on_monitor_id"
  end

  create_table "monitors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "check_interval_seconds", default: 300, null: false
    t.datetime "created_at", null: false
    t.integer "current_status", default: 0, null: false
    t.integer "expected_status", default: 200, null: false
    t.string "http_method", default: "GET", null: false
    t.boolean "is_active", default: true, null: false
    t.datetime "last_checked_at"
    t.string "name", null: false
    t.integer "timeout_ms", default: 5000, null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["current_status"], name: "index_monitors_on_current_status"
    t.index ["is_active"], name: "index_monitors_on_is_active"
  end

  create_table "notification_channels", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "channel_type", default: 0, null: false
    t.jsonb "config", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_notification_channels_on_active"
    t.index ["channel_type"], name: "index_notification_channels_on_channel_type"
  end

  add_foreign_key "checks", "monitors"
  add_foreign_key "incident_updates", "incidents"
  add_foreign_key "incidents_monitors", "incidents"
  add_foreign_key "incidents_monitors", "monitors"
end
