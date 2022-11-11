# frozen_string_literal: true

class CreateLikedSongsPlaylists < ActiveRecord::Migration[7.0]
  def change
    create_table :liked_songs_playlists do |t|
      t.integer :song_count
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
