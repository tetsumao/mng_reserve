# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_22_174302) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "items", force: :cascade do |t|
    t.string "item_name", null: false
    t.integer "stock"
    t.text "description"
    t.integer "dspo", default: 0
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["deleted_at"], name: "index_items_on_deleted_at"
  end

  create_table "mng_reservations", force: :cascade do |t|
    t.string "user_name"
    t.bigint "item_id", null: false
    t.integer "number", default: 1, null: false
    t.string "reservation_name", default: "", null: false
    t.date "reservation_date", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.integer "web_reservation_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_id"], name: "index_mng_reservations_on_item_id"
  end

  create_table "staffs", force: :cascade do |t|
    t.string "login_name", null: false
    t.string "password_digest"
    t.string "staff_name"
    t.integer "dspo", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index "lower((login_name)::text)", name: "index_staffs_on_LOWER_login_name", unique: true
  end

  create_table "web_reservations", force: :cascade do |t|
    t.integer "user_id"
    t.string "user_name"
    t.bigint "item_id", null: false
    t.integer "number", default: 1, null: false
    t.string "reservation_name", default: "", null: false
    t.date "reservation_date", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.datetime "sent_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_id"], name: "index_web_reservations_on_item_id"
  end

  add_foreign_key "mng_reservations", "items"
  add_foreign_key "web_reservations", "items"
end
