# frozen_string_literal: true

class AddUniqueIndices < ActiveRecord::Migration[7.0]
  def change
    remove_index :smart_playlists, :playlist_id
    remove_index :oauth_credentials, :user_id
    remove_index :liked_songs_playlists, :user_id
    remove_index :rule_groups, :smart_playlist_id

    add_index :smart_playlists, :playlist_id, unique: true
    add_index :oauth_credentials, :user_id, unique: true
    add_index :liked_songs_playlists, :user_id, unique: true
    add_index :rule_groups, :smart_playlist_id, unique: true
  end
end
