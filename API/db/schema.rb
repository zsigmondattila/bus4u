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

ActiveRecord::Schema[7.0].define(version: 2023_11_26_153217) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", primary_key: "uid", id: :string, default: "", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "email"
    t.string "firstname"
    t.string "lastname"
    t.string "role"
    t.string "phone_number"
    t.string "address"
    t.string "company_uid"
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_admins_on_confirmation_token", unique: true
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_admins_on_uid_and_provider", unique: true
  end

  create_table "buses", primary_key: "bus_uid", id: :string, force: :cascade do |t|
    t.string "company_uid"
    t.string "license_plate"
    t.string "brand"
    t.integer "manufacturing_year"
    t.integer "capacity"
    t.datetime "road_tax"
    t.datetime "insurance"
    t.datetime "technical_exam"
    t.boolean "tracked"
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "current_route_uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cities", primary_key: "city_uid", id: :string, force: :cascade do |t|
    t.string "name"
    t.string "zip_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "companies", primary_key: "company_uid", id: :string, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone_number"
    t.string "tax_number"
    t.string "city"
    t.string "office_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "company_stations", primary_key: "company_station_uid", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "email_verifications", force: :cascade do |t|
    t.string "email"
    t.string "verification_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", primary_key: "payment_uid", id: :string, force: :cascade do |t|
    t.string "ticket_id"
    t.string "stripe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ticket_id"], name: "index_payments_on_ticket_id"
  end

  create_table "route_stations", primary_key: "route_station_uid", id: :string, force: :cascade do |t|
    t.string "station_uid"
    t.string "route_uid"
    t.string "name"
    t.datetime "departure_time"
    t.integer "sequence"
    t.decimal "fare"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "routes", primary_key: "route_uid", id: :string, force: :cascade do |t|
    t.string "company_uid"
    t.string "name"
    t.integer "nr_of_stations"
    t.decimal "basic_fare"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stations", primary_key: "station_uid", id: :string, force: :cascade do |t|
    t.string "name"
    t.decimal "longitude"
    t.decimal "latitude"
    t.string "city_uid"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tickets", primary_key: "ticket_uid", id: :string, force: :cascade do |t|
    t.string "company_uid"
    t.string "user_uid"
    t.string "type"
    t.string "route_uid"
    t.string "from_station_uid"
    t.string "to_station_uid"
    t.datetime "date_of_purchase"
    t.datetime "expiration_date"
    t.boolean "is_valid"
    t.boolean "is_paid"
    t.integer "payment_method"
    t.decimal "ticket_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", primary_key: "uid", id: :string, default: "", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "firstname"
    t.string "lastname"
    t.string "email"
    t.string "phone_number"
    t.string "language"
    t.string "stripe_id"
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "payments", "tickets", primary_key: "ticket_uid"
end
