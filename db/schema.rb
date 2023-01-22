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

ActiveRecord::Schema[7.0].define(version: 2022_12_18_215223) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "rule_condition", ["any_artists_genre", "all_artists_genre"]
  create_enum "rule_group_criterion", ["any_pass"]
  create_enum "scraping_status", ["incomplete", "completed"]

  create_table "artists", force: :cascade do |t|
    t.string "name", null: false
    t.string "spotify_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["spotify_id"], name: "index_artists_on_spotify_id", unique: true
  end

  create_table "artists_genres", force: :cascade do |t|
    t.bigint "artist_id", null: false
    t.bigint "genre_id", null: false
    t.boolean "fallback_genre", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id", "genre_id"], name: "index_by_artist_and_genre", unique: true
    t.index ["artist_id"], name: "index_artists_genres_on_artist_id"
    t.index ["genre_id"], name: "index_artists_genres_on_genre_id"
  end

  create_table "artists_tracks", id: false, force: :cascade do |t|
    t.bigint "track_id", null: false
    t.bigint "artist_id", null: false
    t.index ["artist_id"], name: "index_artists_tracks_on_artist_id"
    t.index ["track_id", "artist_id"], name: "index_artists_tracks_on_track_id_and_artist_id", unique: true
    t.index ["track_id"], name: "index_artists_tracks_on_track_id"
  end

  create_table "genres", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_genres_on_name", unique: true
  end

  create_table "liked_songs_playlists", force: :cascade do |t|
    t.integer "song_count"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_liked_songs_playlists_on_user_id", unique: true
  end

  create_table "oauth_credentials", force: :cascade do |t|
    t.string "access_token", null: false
    t.string "refresh_token", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_oauth_credentials_on_user_id", unique: true
  end

  create_table "playlists", force: :cascade do |t|
    t.string "name", null: false
    t.string "spotify_id", null: false
    t.integer "song_count"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_playlists_on_name"
    t.index ["spotify_id"], name: "index_playlists_on_spotify_id", unique: true
    t.index ["user_id"], name: "index_playlists_on_user_id"
  end

  create_table "playlists_current_track_data_imports", force: :cascade do |t|
    t.string "playlist_type", null: false
    t.bigint "playlist_id", null: false
    t.bigint "track_data_import_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["playlist_type", "playlist_id"], name: "index_playlists_current_track_data_imports_on_playlist", unique: true
    t.index ["track_data_import_id"], name: "index_playlists_current_track_data_on_track_data_import_id"
  end

  create_table "rule_groups", force: :cascade do |t|
    t.bigint "smart_playlist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "criterion", default: "any_pass", null: false, enum_type: "rule_group_criterion"
    t.index ["smart_playlist_id"], name: "index_rule_groups_on_smart_playlist_id", unique: true
  end

  create_table "rules", force: :cascade do |t|
    t.bigint "rule_group_id", null: false
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "condition", default: "any_artists_genre", null: false, enum_type: "rule_condition"
    t.index ["rule_group_id"], name: "index_rules_on_rule_group_id"
  end

  create_table "smart_playlists", force: :cascade do |t|
    t.bigint "playlist_id", null: false
    t.integer "track_limit", default: 10000, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["playlist_id"], name: "index_smart_playlists_on_playlist_id", unique: true
  end

  create_table "track_data_imports", force: :cascade do |t|
    t.string "playlist_type", null: false
    t.bigint "playlist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "scraping_status", default: "incomplete", null: false, enum_type: "scraping_status"
    t.index ["playlist_type", "playlist_id"], name: "index_track_data_on_playlist"
  end

  create_table "track_data_imports_tracks", force: :cascade do |t|
    t.bigint "track_data_import_id", null: false
    t.bigint "track_id", null: false
    t.index ["track_data_import_id"], name: "index_track_data_imports_tracks_on_track_data_import_id"
    t.index ["track_id"], name: "index_track_data_imports_tracks_on_track_id"
  end

  create_table "tracks", force: :cascade do |t|
    t.string "name", null: false
    t.string "spotify_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["spotify_id"], name: "index_tracks_on_spotify_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "full_name", null: false
    t.string "preferred_name"
    t.string "spotify_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["spotify_id"], name: "index_users_on_spotify_id", unique: true
  end

  add_foreign_key "artists_genres", "artists"
  add_foreign_key "artists_genres", "genres"
  add_foreign_key "artists_tracks", "artists"
  add_foreign_key "artists_tracks", "tracks"
  add_foreign_key "liked_songs_playlists", "users"
  add_foreign_key "oauth_credentials", "users"
  add_foreign_key "playlists", "users"
  add_foreign_key "playlists_current_track_data_imports", "track_data_imports"
  add_foreign_key "rule_groups", "smart_playlists"
  add_foreign_key "rules", "rule_groups"
  add_foreign_key "smart_playlists", "playlists"
  add_foreign_key "track_data_imports_tracks", "track_data_imports"
  add_foreign_key "track_data_imports_tracks", "tracks"
end
