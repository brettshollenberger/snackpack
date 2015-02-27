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

ActiveRecord::Schema.define(version: 20150227081441) do

  create_table "campaigns", force: :cascade do |t|
    t.string   "name",       limit: 255,                    null: false
    t.string   "queue",      limit: 255, default: "medium"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "user_id",    limit: 4,                      null: false
  end

  add_index "campaigns", ["name", "user_id"], name: "index_campaigns_on_name_and_user_id", unique: true, using: :btree
  add_index "campaigns", ["user_id"], name: "fk_rails_d5ca668f2d", using: :btree

  create_table "deliveries", force: :cascade do |t|
    t.integer  "template_id",  limit: 4,                 null: false
    t.integer  "recipient_id", limit: 4,                 null: false
    t.integer  "sender_id",    limit: 4,                 null: false
    t.datetime "send_at"
    t.datetime "sent_at"
    t.text     "data",         limit: 65535
    t.integer  "status",       limit: 4,     default: 0
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "campaign_id",  limit: 4,                 null: false
  end

  add_index "deliveries", ["campaign_id"], name: "fk_rails_af90e3ac35", using: :btree
  add_index "deliveries", ["recipient_id"], name: "fk_recipient_id", using: :btree
  add_index "deliveries", ["sender_id"], name: "fk_sender_id", using: :btree
  add_index "deliveries", ["template_id", "campaign_id", "recipient_id"], name: "index_deliveries_on_template_id_and_campaign_id_and_recipient_id", unique: true, using: :btree

  create_table "recipients", force: :cascade do |t|
    t.string   "first_name", limit: 255,             null: false
    t.string   "last_name",  limit: 255,             null: false
    t.string   "email",      limit: 255,             null: false
    t.integer  "status",     limit: 4,   default: 0
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "sender_id",  limit: 4,               null: false
  end

  add_index "recipients", ["email"], name: "index_recipients_on_email", unique: true, using: :btree
  add_index "recipients", ["sender_id", "email"], name: "index_recipients_on_sender_id_and_email", unique: true, using: :btree

  create_table "templates", force: :cascade do |t|
    t.string   "name",        limit: 255,                          null: false
    t.string   "subject",     limit: 255,   default: "No subject"
    t.text     "html",        limit: 65535
    t.text     "text",        limit: 65535
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "provider",    limit: 4,     default: 0
    t.integer  "campaign_id", limit: 4
    t.integer  "user_id",     limit: 4,                            null: false
  end

  add_index "templates", ["campaign_id"], name: "fk_rails_e130c9791e", using: :btree
  add_index "templates", ["name", "user_id"], name: "index_templates_on_name_and_user_id", unique: true, using: :btree
  add_index "templates", ["user_id"], name: "fk_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name",             limit: 255,              null: false
    t.string   "last_name",              limit: 255,              null: false
    t.string   "email",                  limit: 255,              null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "authentication_token",   limit: 255,              null: false
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "campaigns", "users"
  add_foreign_key "deliveries", "campaigns"
  add_foreign_key "deliveries", "recipients", name: "fk_recipient_id"
  add_foreign_key "deliveries", "templates", name: "fk_template_id"
  add_foreign_key "deliveries", "users", column: "sender_id", name: "fk_sender_id"
  add_foreign_key "recipients", "users", column: "sender_id"
  add_foreign_key "templates", "campaigns"
  add_foreign_key "templates", "users", name: "fk_user_id"
end
