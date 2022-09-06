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

ActiveRecord::Schema[7.0].define(version: 2022_09_06_060953) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_logs", force: :cascade do |t|
    t.string "request_url", null: false
    t.json "request_headers"
    t.json "request_params"
    t.json "request_body"
    t.integer "response_status", null: false
    t.json "response_headers"
    t.json "response_body"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_api_logs_on_user_id"
  end

  create_table "oauth_credentials", force: :cascade do |t|
    t.string "access_token", null: false
    t.string "refresh_token", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_oauth_credentials_on_user_id"
  end

  create_table "playlists", force: :cascade do |t|
    t.string "name", null: false
    t.string "playlist_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_playlists_on_name"
    t.index ["user_id"], name: "index_playlists_on_user_id"
  end

  create_table "track_data", force: :cascade do |t|
    t.bigint "playlist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["playlist_id"], name: "index_track_data_on_playlist_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "full_name", null: false
    t.string "preferred_name"
    t.string "spotify_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["spotify_id"], name: "index_users_on_spotify_id"
  end

  add_foreign_key "api_logs", "users"
  add_foreign_key "oauth_credentials", "users"
  add_foreign_key "playlists", "users"
  add_foreign_key "track_data", "playlists"
end
