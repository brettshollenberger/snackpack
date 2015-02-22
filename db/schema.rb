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

ActiveRecord::Schema.define(version: 20150222020309) do

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
  end

  add_index "deliveries", ["recipient_id"], name: "fk_recipient_id", using: :btree
  add_index "deliveries", ["sender_id"], name: "fk_sender_id", using: :btree
  add_index "deliveries", ["template_id"], name: "fk_template_id", using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           limit: 255, null: false
    t.integer  "sluggable_id",   limit: 4,   null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope",          limit: 255
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "templates", force: :cascade do |t|
    t.string   "name",       limit: 255,   null: false
    t.string   "slug",       limit: 255,   null: false
    t.string   "subject",    limit: 255
    t.text     "html",       limit: 65535
    t.text     "text",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "templates", ["slug"], name: "index_templates_on_slug", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name", limit: 255,             null: false
    t.string   "last_name",  limit: 255,             null: false
    t.string   "email",      limit: 255,             null: false
    t.integer  "role",       limit: 4,   default: 0
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  add_foreign_key "deliveries", "templates", name: "fk_template_id"
  add_foreign_key "deliveries", "users", column: "recipient_id", name: "fk_recipient_id"
  add_foreign_key "deliveries", "users", column: "sender_id", name: "fk_sender_id"
end
